//
//  WorkflowRunner.swift
//  Workflow
//
//  Created by Vlad Maltsev on 30.12.2025.
//

import Core
import Foundation
import os

private struct AutomaticStepSignature: Hashable {
    let state: StateID
    let transitionId: TransitionID
    let data: WorkflowData
}

actor WorkflowRunner {
    let storage: WorkflowStorage
    let registry: WorkflowRegistry
    private let dependencies: DependenciesContainer
    private let plugins: Plugins

    lazy var scheduler = WaitScheduler { [weak self] instanceId, reason in
        await self?.resumeWaiting(instanceId: instanceId, reason: reason)
    }
    let logger = Logger(scope: .workflow)

    /// Per-instance serialization queue. See `WorkflowRunner+InstanceLock.swift`.
    var inflight: [WorkflowInstanceID: Task<Void, Never>] = [:]

    init(storage: WorkflowStorage, registry: WorkflowRegistry, dependencies: DependenciesContainer, plugins: Plugins) {
        self.storage = storage
        self.registry = registry
        self.dependencies = dependencies
        self.plugins = plugins
    }

    func create(_ workflow: AnyWorkflow, initialData: WorkflowData) async throws -> WorkflowInstance {
        logger?.trace("Create \(workflow.id, privacy: .public)")
        return try await storage.create(workflow, initialData: initialData)
    }

    func start(_ workflow: AnyWorkflow, initialData: WorkflowData) async throws -> WorkflowInstance {
        logger?.trace("Start \(workflow.id, privacy: .public)")
        let instance = try await create(workflow, initialData: initialData)
        await plugins.invoke(WorkflowTransitionListener.self) {
            $0.workflowDidStart(instance: instance)
        }
        return await runAutomaticTransitions(from: instance)
    }

    @discardableResult
    func takeTransition(processId: TransitionProcessID, on instanceId: WorkflowInstanceID) async throws -> WorkflowInstance {
        // Resolve against a snapshot before queueing, so a transition that is
        // not available fails right away instead of waiting behind a running one.
        let snapshot = try await loadInstance(instanceId)
        guard let workflow = await registry.workflow(id: snapshot.workflowId) else {
            throw WorkflowsError.WorkflowNotFound(workflowId: snapshot.workflowId)
        }
        let candidates = workflow.anyTransitions.filter { $0.from == snapshot.state && $0.id.processId == processId }
        guard let transition = candidates.first, candidates.count == 1 else {
            throw WorkflowsError.TransitionProcessNotFoundForInstance(
                instance: instanceId,
                workflow: workflow.id,
                transitionId: processId,
                availableTransitions: workflow.anyTransitions.map(\.id)
            )
        }

        return try await withInstanceLock(instanceId) { [self] in
            // Re-load under the lock; an earlier queued operation on this id
            // may have advanced the instance past the snapshot.
            let instance = try await loadInstance(instanceId)
            guard instance.state == transition.from else {
                throw WorkflowsError.TransitionProcessNotFoundForInstance(
                    instance: instanceId,
                    workflow: workflow.id,
                    transitionId: processId,
                    availableTransitions: workflow.anyTransitions
                        .filter { $0.from == instance.state }
                        .map(\.id)
                )
            }
            return try await takeTransitionLocked(transition, on: instance, of: workflow)
        }
    }

    /// Takes `transition` and then follows the automatic chain from the state it leads to.
    @discardableResult
    private func takeTransitionLocked(
        _ transition: AnyTransition,
        on instance: WorkflowInstance,
        of workflow: AnyWorkflow,
        resumeReason: WaitScheduler.ResumeReason? = nil
    ) async throws -> WorkflowInstance {
        let next = try await executeTransitionLocked(transition, on: instance, of: workflow, resumeReason: resumeReason)
        return await runAutomaticTransitionsLocked(from: next)
    }

    /// Executes exactly one transition and persists its result. It must not continue into the
    /// automatic chain itself: the chain is one flat loop in `runAutomaticTransitionsLocked`, so
    /// that its loop protection sees every step. Re-entering the chain from here would give each
    /// step a fresh seen-set and step counter.
    private func executeTransitionLocked(
        _ transition: AnyTransition,
        on instance: WorkflowInstance,
        of workflow: AnyWorkflow,
        resumeReason: WaitScheduler.ResumeReason? = nil
    ) async throws -> WorkflowInstance {
        logger?.trace("Take transition \(transition.id.debugDescription, privacy: .public) for \(workflow.id, privacy: .public)")

        try checkVersion(of: instance, against: workflow)

        let traceId = UUID()
        await plugins.invoke(WorkflowTransitionListener.self) {
            $0.workflowWillTransition(instance: instance, transition: transition.id, traceId: traceId)
        }

        let executing = instance.transitionExecuting(transition)
        try await storage.update(executing)

        var context = WorkflowContext(
            instance: executing,
            resume: resumeReason,
            dependencies: dependencies,
            startSubflow: self.start
        )
        let result = try await executeTransitionProcess(transition, on: instance, context: &context)

        await plugins.invoke(WorkflowTransitionListener.self) {
            $0.workflowDidTransition(instance: instance, transition: transition.id, traceId: traceId)
        }

        var next = instance.data(context.instance.data)
        switch result {
            case .completed:
                let target = context.routedTarget ?? transition.targets[0]
                guard transition.targets.contains(target) else {
                    throw WorkflowsError.InvalidRouteTarget(
                        transitionId: transition.id,
                        requestedTarget: target,
                        allowedTargets: transition.targets
                    )
                }
                next = next.transitionEnded().moveToState(target)
            case .waiting(let waiting):
                next = next.transitionWaiting(waiting, of: transition)
                await scheduler.schedule(for: next.id, waiting: waiting)
        }

        if next.state == workflow.finishId {
            try await finish(next)
        } else {
            try await storage.update(next)
        }

        return next
    }

    private func executeTransitionProcess(
        _ transition: AnyTransition,
        on instance: WorkflowInstance,
        context: inout WorkflowContext
    ) async throws -> TransitionResult {
        do {
            return try await transition.process.start(context: &context)
        } catch {
            let failed = instance.transitionFailed(error, at: transition)
            do {
                try await storage.update(failed)
            } catch let persistError {
                logger?.error("Failed to persist failure state for \(instance.id, privacy: .public): \(persistError, privacy: .public)")
                throw Failure(
                    // swiftlint:disable:next line_length
                    "Transition \(transition.id.processId) failed and the failure state could not be persisted; instance \(instance.id) is in an unknown state",
                    underlyingError: persistError
                )
            }
            throw error
        }
    }

    private func finish(_ instance: WorkflowInstance) async throws {
        logger?.trace("Finish \(instance.id, privacy: .public)")
        try await storage.finish(instance)
        await plugins.invoke(WorkflowTransitionListener.self) {
            $0.workflowDidFinish(instance: instance)
        }
        await scheduler.notifyFinished(instance.id, data: instance.data)
    }

    // MARK: - Ask

    @discardableResult
    func answerAsk(instanceId: WorkflowInstanceID, data: WorkflowData) async throws -> WorkflowInstance {
        let snapshot = try await loadInstance(instanceId)
        guard case .waiting(.asking) = snapshot.transitionState?.state else {
            throw WorkflowsError.InstanceNotAsking(instanceId: instanceId)
        }
        guard let instance = try await resumeTransition(on: instanceId, reason: .answered(data: data)) else {
            throw WorkflowsError.InstanceNotAsking(instanceId: instanceId)
        }
        return instance
    }

    // MARK: - Waiting

    private func resumeWaiting(instanceId: WorkflowInstanceID, reason: WaitScheduler.ResumeReason) async {
        logger?.trace("Resume waiting \(instanceId.debugDescription, privacy: .public)")
        do {
            if try await resumeTransition(on: instanceId, reason: reason) == nil {
                logger?.error("Failed to resolve waiting context for \(instanceId, privacy: .public)")
            }
        } catch {
            logger?.error("Failed to resume \(instanceId, privacy: .public) with error \(error, privacy: .public)")
        }
    }

    /// Takes the transition recorded in the instance's `transitionState` again, under the lock.
    /// Returns `nil` when the instance or that transition can no longer be resolved.
    private func resumeTransition(
        on instanceId: WorkflowInstanceID,
        reason: WaitScheduler.ResumeReason
    ) async throws -> WorkflowInstance? {
        try await withInstanceLock(instanceId) { [self] in
            guard
                let instance = try await storage.instance(id: instanceId),
                let transitionId = instance.transitionState?.transitionId,
                reason.resumes(instance.transitionState?.state),
                let workflow = await registry.workflow(id: instance.workflowId),
                let transition = workflow.anyTransitions.first(where: { $0.id == transitionId })
            else {
                return nil
            }
            return try await takeTransitionLocked(transition, on: instance, of: workflow, resumeReason: reason)
        }
    }

    // MARK: - Lookup

    private func loadInstance(_ instanceId: WorkflowInstanceID) async throws -> WorkflowInstance {
        guard let instance = try await storage.instance(id: instanceId) else {
            throw WorkflowsError.WorkflowInstanceNotFound(instanceId: instanceId)
        }
        return instance
    }

    private func checkVersion(of instance: WorkflowInstance, against workflow: AnyWorkflow) throws {
        guard instance.workflowVersion == workflow.version else {
            throw WorkflowsError.WorkflowVersionMismatch(
                instanceId: instance.id,
                workflowId: instance.workflowId,
                instanceVersion: instance.workflowVersion,
                workflowVersion: workflow.version
            )
        }
    }
}

// MARK: - Automatic transitions

extension WorkflowRunner {
    @discardableResult
    func runAutomaticTransitions(from start: WorkflowInstance) async -> WorkflowInstance {
        await withInstanceLock(start.id) { [self] in
            await runAutomaticTransitionsLocked(from: start)
        }
    }

    @discardableResult
    private func runAutomaticTransitionsLocked(from start: WorkflowInstance) async -> WorkflowInstance {
        var current = start
        var steps = 0
        var seen: Set<AutomaticStepSignature> = []
        let maxSteps = 100

        while let (transition, workflow) = await findAutomaticTransition(from: current) {
            let signature = AutomaticStepSignature(
                state: current.state,
                transitionId: transition.id,
                data: current.data
            )

            // A chain may use all `maxSteps` and end on its own; it only fails
            // when another automatic step is still pending after that.
            let chainError: (any Error)?
            if steps >= maxSteps {
                chainError = WorkflowsError.AutomaticStepLimitReached(
                    instanceId: current.id,
                    state: current.state,
                    transitionId: transition.id,
                    limit: maxSteps
                )
            } else if !seen.insert(signature).inserted {
                chainError = WorkflowsError.AutomaticLoopDetected(
                    instanceId: current.id,
                    state: current.state,
                    transitionId: transition.id
                )
            } else {
                chainError = nil
            }

            if let chainError {
                logger?.error("Automatic chain stopped on \(current.id, privacy: .public): \(chainError, privacy: .public)")
                let failed = current.transitionFailed(chainError, at: transition)
                do {
                    try await storage.update(failed)
                } catch let persistError {
                    logger?.error("Failed to persist automatic chain failure: \(persistError, privacy: .public)")
                }
                return failed
            }

            guard let next = await executeAutomatic(transition: transition, on: current, of: workflow) else {
                break
            }
            current = next
            steps += 1
        }
        return current
    }

    private func findAutomaticTransition(
        from instance: WorkflowInstance
    ) async -> (AnyTransition, AnyWorkflow)? {
        guard instance.transitionState == nil else {
            return nil
        }

        guard let workflow = await registry.workflow(instance: instance) else {
            logger?.error("Workflow for instance \(instance.id) of type \(instance.workflowId) not found")
            return nil
        }

        let automatic = workflow.anyTransitions.filter { $0.from == instance.state && $0.trigger == .automatic }
        guard let transition = automatic.first, automatic.count == 1 else {
            if automatic.isEmpty {
                logger?.trace("No automatic transitions from \(instance.state, privacy: .public)")
            } else {
                // swiftlint:disable:next line_length
                logger?.error("Multiple automatic transitions from state \(instance.state, privacy: .public): \(automatic.map(\.id), privacy: .public)")
            }
            return nil
        }

        return (transition, workflow)
    }

    private func executeAutomatic(
        transition: AnyTransition,
        on instance: WorkflowInstance,
        of workflow: AnyWorkflow
    ) async -> WorkflowInstance? {
        logger?.trace("Auto transition \(transition.id.processId, privacy: .public)")
        do {
            return try await executeTransitionLocked(transition, on: instance, of: workflow)
        } catch {
            let failed = instance.transitionFailed(error, at: transition)
            logger?.error("Transition \(transition.id.processId, privacy: .public) failed \(error, privacy: .public)")
            do {
                try await storage.update(failed)
                return failed
            } catch let persistError {
                // swiftlint:disable:next line_length
                logger?.error("Failed to persist failure state for \(instance.id, privacy: .public): \(persistError, privacy: .public); halting automatic chain")
                return nil
            }
        }
    }
}
