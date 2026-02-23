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

    private lazy var scheduler: WaitScheduler = WaitScheduler { [weak self] instanceId in
        await self?.resumeWaiting(instanceId: instanceId)
    }
    private let logger = Logger(scope: .workflow)

    init(storage: WorkflowStorage, registry: WorkflowRegistry, dependencies: DependenciesContainer) {
        self.storage = storage
        self.registry = registry
        self.dependencies = dependencies
    }

    func resume() async throws {
        let instances = try await storage.all()
        logger?.trace("Resume runner (\(instances.count) instances)")
        await scheduler.rebuild(from: instances)
        for instance in instances {
            await takeAutomaticTransitionsLoop(from: instance)
        }
    }

    func start(_ workflow: AnyWorkflow, initialData: WorkflowData) async throws -> WorkflowInstance {
        logger?.trace("Start \(workflow.id, privacy: .public)")
        let instance = try await storage.create(workflow, initialData: initialData)
        return await takeAutomaticTransitionsLoop(from: instance)
    }

    @discardableResult
    func takeTransition(_ transition: AnyTransition, on instance: WorkflowInstance, of workflow: AnyWorkflow) async throws -> WorkflowInstance {
        logger?.trace("Take transition \(transition.id.debugDescription, privacy: .public) for \(workflow.id, privacy: .public)")

        var context = WorkflowContext(data: instance.data, dependancyContainer: dependencies, start: self.start)
        let result = try await transition.process.start(context: &context)

        var next = instance.data(context.data)
        switch result {
        case .completed:
            next = next.transitionEnded().moveToState(transition.to)
        case .waiting(let waiting):
            next = next.transitionWaiting(waiting, of: transition)
            await scheduler.schedule(for: next.id, waiting: waiting)
        }

        if next.state == workflow.finishId {
            try await finish(next)
        } else {
            try await storage.update(next)
        }

        return await takeAutomaticTransitionsLoop(from: next)
    }

    func finish(_ instance: WorkflowInstance) async throws {
        logger?.trace("Finish \(instance.id, privacy: .public)")
        try await storage.finish(instance)
        await scheduler.notifyFinished(instance.id)
    }

    // MARK: - Automatic transitions

    @discardableResult
    private func takeAutomaticTransitionsLoop(from start: WorkflowInstance) async -> WorkflowInstance {
        var current = start
        while let next = await nextAutomaticTransitionInstance(from: current) {
            current = next
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
            if automatic.isEmpty { logger?.trace("No automatic transitions from \(instance.state, privacy: .public)") }
            else { logger?.error("Multiple automatic transitions from state \(instance.state, privacy: .public): \(automatic.map(\.id), privacy: .public)") }
            return nil
        }

        logger?.trace("Auto transition \(transition.id.processId, privacy: .public)")
        do {
            return try await takeTransition(transition, on: instance, of: workflow)
        } catch {
            let failed = instance.transitionFailed(error, at: transition)
            logger?.error("Transition \(transition.id.processId, privacy: .public) failed \(error, privacy: .public)")
            try? await storage.update(failed)
            return failed
        }
    }

    // MARK: - Waiting

    private func resumeWaiting(instanceId: WorkflowInstanceID) async {
        logger?.trace("Resume waiting \(instanceId.debugDescription, privacy: .public)")

        guard let instance = try? await storage.instance(id: instanceId),
              let transitionState = instance.transitionState,
              let workflow = await registry.workflow(id: instance.workflowId),
              let transition = workflow.anyTransitions.first(where: { $0.id == transitionState.transitionId }) else {
            logger?.error("Failed to resolve waiting context for \(instanceId, privacy: .public)")
            return
        }

        do {
            try await takeTransition(transition, on: instance, of: workflow)
        } catch {
            try? await storage.update(instance.transitionFailed(error, at: transition))
            logger?.error("Failed to resume \(instanceId, privacy: .public) with error \(error, privacy: .public)")
        }
    }
}

