//
//  WorkflowRunner.swift
//  Workflow
//
//  Created by Vlad Maltsev on 30.12.2025.
//

import Core
import Foundation
import os

actor WorkflowRunner {
    private let storage: WorkflowStorage
    private let registry: WorkflowRegistry
    private let dependencies: DependenciesContainer
    private let plugins: Plugins

    private lazy var scheduler = WaitScheduler { [weak self] instanceId, reason in
        await self?.resumeWaiting(instanceId: instanceId, reason: reason)
    }
    private let logger = Logger(scope: .workflow)

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
        let result: TransitionResult
        do {
            result = try await transition.process.start(context: &context)
        } catch {
            let failed = instance.transitionFailed(error, at: transition)
            do {
                try await storage.update(failed)
            } catch {
                logger?.error("Failed to persist failure state for \(instance.id, privacy: .public): \(error, privacy: .public)")
            }
            throw error
        }

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

        return await runAutomaticTransitions(from: next)
    }

    func finish(_ instance: WorkflowInstance) async throws {
        logger?.trace("Finish \(instance.id, privacy: .public)")
        try await storage.finish(instance)
        await plugins.invoke(WorkflowTransitionListener.self) {
            $0.workflowDidFinish(instance: instance)
        }
        await scheduler.notifyFinished(instance.id, data: instance.data)
    }

    // MARK: - Automatic transitions

    @discardableResult
    func runAutomaticTransitions(from start: WorkflowInstance) async -> WorkflowInstance {
        var current = start
        var steps = 0
        let maxSteps = 1000
        while let next = await nextAutomaticTransitionInstance(from: current) {
            current = next
            steps += 1
            if steps >= maxSteps {
                logger?.error("Automatic transition limit (\(maxSteps)) reached for \(current.id)")
                break
            }
        }
        return current
    }

    private func nextAutomaticTransitionInstance(from instance: WorkflowInstance) async -> WorkflowInstance? {
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

        logger?.trace("Auto transition \(transition.id.processId, privacy: .public)")
        do {
            return try await takeTransition(transition, on: instance, of: workflow)
        } catch {
            let failed = instance.transitionFailed(error, at: transition)
            logger?.error("Transition \(transition.id.processId, privacy: .public) failed \(error, privacy: .public)")
            do {
                try await storage.update(failed)
            } catch {
                logger?.error("Failed to persist failure state for \(instance.id, privacy: .public): \(error, privacy: .public)")
            }
            return failed
        }
    }

    // MARK: - Ask

    @discardableResult
    func answerAsk(instanceId: WorkflowInstanceID, data: WorkflowData) async throws -> WorkflowInstance {
        let instance = try await storage.instance(id: instanceId)

        guard
            let instance,
            let transitionState = instance.transitionState,
            let workflow = await registry.workflow(id: instance.workflowId),
            let transition = workflow.anyTransitions.first(where: { $0.id == transitionState.transitionId })
        else {
            throw WorkflowsError.InstanceNotAsking(instanceId: instanceId)
        }

        return try await takeTransition(transition, on: instance, of: workflow, resumeReason: .answered(data: data))
    }

    // MARK: - Waiting

    private func resumeWaiting(instanceId: WorkflowInstanceID, reason: WaitScheduler.ResumeReason) async {
        logger?.trace("Resume waiting \(instanceId.debugDescription, privacy: .public)")

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
            try await takeTransition(transition, on: instance, of: workflow, resumeReason: reason)
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
