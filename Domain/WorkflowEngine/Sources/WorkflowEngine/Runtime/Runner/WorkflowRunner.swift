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
    private let storage: WorkflowStorage
    private let registry: WorkflowRegistry
    private let dependencies: DependenciesContainer
    private let plugins: Plugins

    private lazy var scheduler = WaitScheduler { [weak self] instanceId, reason in
        await self?.resumeWaiting(instanceId: instanceId, reason: reason)
    }
    private let logger = Logger(scope: .workflow)

    /// Per-instance serialization queue. See `WorkflowRunner+InstanceLock.swift`.
    var inflight: [WorkflowInstanceID: InflightEntry] = [:]

    init(storage: WorkflowStorage, registry: WorkflowRegistry, dependencies: DependenciesContainer, plugins: Plugins) {
        self.storage = storage
        self.registry = registry
        self.dependencies = dependencies
        self.plugins = plugins
    }

    func resume() async throws {
        let instances = try await storage.all()
        logger?.trace("Resume runner (\(instances.count) instances)")
        await scheduler.rebuild(from: instances)
        for instance in instances {
            if let workflow = await registry.workflow(instance: instance) {
                guard instance.workflowVersion == workflow.version else {
                    throw WorkflowsError.WorkflowVersionMismatch(
                        instanceId: instance.id,
                        workflowId: instance.workflowId,
                        instanceVersion: instance.workflowVersion,
                        workflowVersion: workflow.version
                    )
                }
            }
            await runAutomaticTransitions(from: instance)
        }
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
    func takeTransition(
        _ transition: AnyTransition,
        on instance: WorkflowInstance,
        of workflow: AnyWorkflow,
        resumeReason: WaitScheduler.ResumeReason? = nil
    ) async throws -> WorkflowInstance {
        try await withInstanceLock(instance.id) { [self] in
            try await takeTransitionLocked(transition, on: instance, of: workflow, resumeReason: resumeReason)
        }
    }

    @discardableResult
    private func takeTransitionLocked(
        _ transition: AnyTransition,
        on instance: WorkflowInstance,
        of workflow: AnyWorkflow,
        resumeReason: WaitScheduler.ResumeReason? = nil
    ) async throws -> WorkflowInstance {
        logger?.trace("Take transition \(transition.id.debugDescription, privacy: .public) for \(workflow.id, privacy: .public)")

        guard instance.workflowVersion == workflow.version else {
            throw WorkflowsError.WorkflowVersionMismatch(
                instanceId: instance.id,
                workflowId: instance.workflowId,
                instanceVersion: instance.workflowVersion,
                workflowVersion: workflow.version
            )
        }

        let traceId = UUID()
        await plugins.invoke(WorkflowTransitionListener.self) {
            $0.workflowWillTransition(instance: instance, transition: transition.id, traceId: traceId)
        }

        let executing = instance.transitionExecuting(transition)
        try await storage.update(executing)

        var context = WorkflowContext(
            instance: executing,
            resume: resumeReason,
            dependancyContainer: dependencies,
            start: self.start
        )
        let result = try await executeTransitionProcess(transition, on: instance, context: &context)

        await plugins.invoke(WorkflowTransitionListener.self) {
            $0.workflowDidTransition(instance: instance, transition: transition.id, traceId: traceId)
        }

        var next = instance.data(context.instance.data)
        switch result {
        case .completed:
            let target = context.routedTarget ?? transition.targets[0]
            if let routedTarget = context.routedTarget {
                guard transition.targets.contains(routedTarget) else {
                    throw WorkflowsError.InvalidRouteTarget(
                        transitionId: transition.id,
                        requestedTarget: routedTarget,
                        allowedTargets: transition.targets
                    )
                }
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

        return await runAutomaticTransitionsLocked(from: next)
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

    func finish(_ instance: WorkflowInstance) async throws {
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
        try await withInstanceLock(instanceId) { [self] in
            let instance = try await storage.instance(id: instanceId)

            guard
                let instance,
                let transitionState = instance.transitionState,
                let workflow = await registry.workflow(id: instance.workflowId),
                let transition = workflow.anyTransitions.first(where: { $0.id == transitionState.transitionId })
            else {
                throw WorkflowsError.InstanceNotAsking(instanceId: instanceId)
            }

            return try await takeTransitionLocked(
                transition,
                on: instance,
                of: workflow,
                resumeReason: .answered(data: data)
            )
        }
    }

    // MARK: - Waiting

    private func resumeWaiting(instanceId: WorkflowInstanceID, reason: WaitScheduler.ResumeReason) async {
        logger?.trace("Resume waiting \(instanceId.debugDescription, privacy: .public)")

        await withInstanceLock(instanceId) { [self] in
            let instance: WorkflowInstance?
            do {
                instance = try await storage.instance(id: instanceId)
            } catch {
                logger?.error("Failed to load instance \(instanceId, privacy: .public) from storage: \(error, privacy: .public)")
                return
            }

            guard
                let instance,
                let transitionState = instance.transitionState,
                let workflow = await registry.workflow(id: instance.workflowId),
                let transition = workflow.anyTransitions.first(where: { $0.id == transitionState.transitionId })
            else {
                logger?.error("Failed to resolve waiting context for \(instanceId, privacy: .public)")
                return
            }

            do {
                try await takeTransitionLocked(transition, on: instance, of: workflow, resumeReason: reason)
            } catch {
                do {
                    try await storage.update(instance.transitionFailed(error, at: transition))
                } catch {
                    logger?.error("Failed to persist failure state for \(instanceId, privacy: .public): \(error, privacy: .public)")
                }
                logger?.error("Failed to resume \(instanceId, privacy: .public) with error \(error, privacy: .public)")
            }
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
        let maxSteps = 1000

        while let (transition, workflow) = await findAutomaticTransition(from: current) {
            let signature = AutomaticStepSignature(
                state: current.state,
                transitionId: transition.id,
                data: current.data
            )
            if !seen.insert(signature).inserted {
                // swiftlint:disable:next line_length
                logger?.error("Automatic loop detected on \(current.id, privacy: .public) at state \(current.state, privacy: .public) via \(transition.id.processId, privacy: .public)")
                let loopError = WorkflowsError.AutomaticLoopDetected(
                    instanceId: current.id,
                    state: current.state,
                    transitionId: transition.id
                )
                let failed = current.transitionFailed(loopError, at: transition)
                do {
                    try await storage.update(failed)
                } catch let persistError {
                    logger?.error("Failed to persist loop-detection failure: \(persistError, privacy: .public)")
                }
                return failed
            }

            guard let next = await executeAutomatic(transition: transition, on: current, of: workflow) else {
                break
            }
            current = next
            steps += 1
            if steps >= maxSteps {
                logger?.error("Automatic transition limit (\(maxSteps)) reached for \(current.id)")
                break
            }
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
            return try await takeTransitionLocked(transition, on: instance, of: workflow)
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
