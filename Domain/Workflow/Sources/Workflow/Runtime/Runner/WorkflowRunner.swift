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
    private var scheduler: WaitScheduler?

    private let logger = Logger(scope: .workflow)

    init(storage: WorkflowStorage, registry: WorkflowRegistry) {
        self.storage = storage
        self.registry = registry

        Task { [weak self] in
            await self?.initializeScheduler()
        }
    }

    func resume() async throws {
        logger?.trace("Running resumed")
        let instances = try await storage.all()
        await scheduler?.rebuild(from: instances)

        for instance in instances {
            await takeAllAutomaticTransitionsIfNeeded(of: instance)
        }
    }

    func start(_ workflow: AnyWorkflow, initialData: WorkflowData) async throws -> WorkflowInstance {
        logger?.trace("Started \(workflow.id, privacy: .public)")
        let instance = try await storage.create(workflow, initialData: initialData)
        return await takeAutomaticTransitionsIfNeeded(of: instance)
    }

    @discardableResult
    func takeTransition(_ transition: AnyTransition, on instance: WorkflowInstance, of workflow: AnyWorkflow) async throws -> WorkflowInstance {
        logger?.trace("Take transition \(transition.id.debugDescription, privacy: .public) for \(workflow.id, privacy: .public)")

        var context = WorkflowContext(
            data: instance.data,
            start: self.start
        )
        let result = try await transition.process.start(context: &context)

        var nextInstance = instance
            .data(context.data)

        switch result {
        case .completed:
            nextInstance = nextInstance
                .transitionEnded()
                .moveToState(transition.toStateId)
        case .waiting(let waiting):
            nextInstance = nextInstance
                .transitionWaiting(waiting, of: transition)
            await scheduler?.schedule(for: nextInstance.id, waiting: waiting)
        }

        if nextInstance.state == workflow.finalState {
            try await finish(nextInstance)
        } else {
            try await storage.update(nextInstance)
        }

        return await takeAllAutomaticTransitionsIfNeeded(of: nextInstance)
    }

    func finish(_ instance: WorkflowInstance) async throws {
        logger?.trace("Finished \(instance.id, privacy: .public)")
        try await storage.finish(instance)
        await scheduler?.notifyFinished(instance.id)
    }

    @discardableResult
    private func takeAllAutomaticTransitionsIfNeeded(of instance: WorkflowInstance) async -> WorkflowInstance {
        let nextInstance = await takeAutomaticTransitionsIfNeeded(of: instance)
        if nextInstance.state != instance.state {
            return await takeAllAutomaticTransitionsIfNeeded(of: nextInstance)
        } else {
            return nextInstance
        }
    }

    @discardableResult
    private func takeAutomaticTransitionsIfNeeded(of instance: WorkflowInstance) async -> WorkflowInstance {
        logger?.trace("Taking automatic transition from \(instance.state, privacy: .public)")
        guard let workflow = await registry.workflow(instance: instance) else {
            logger?.error("Workflow for instance \(instance.id) of type \(instance.workflowId) not found")
            return instance
        }

        let automaticTransitions = workflow.anyTransitions
            .filter { transition in
                transition.fromStateId == instance.state && transition.trigger == .automatic
            }

        if automaticTransitions.isEmpty {
            logger?.trace("No automatic transitions, skip")
            return instance
        }

        guard automaticTransitions.count == 1 else {
            logger?.error("There are several automatic transitions from state \(instance.state, privacy: .public): \(automaticTransitions.map(\.id), privacy: .public)")
            return instance
        }
        
        let transition = automaticTransitions[0]

        logger?.trace("Found automatic transition \(transition.id.processId, privacy: .public)")

        do {
            return try await takeTransition(transition, on: instance, of: workflow)
        } catch {
            let newInstance = instance.transitionFailed(error, at: transition)
            logger?.error("Transition \(transition.id.processId, privacy: .public) failed \(error, privacy: .public)")
            try? await storage.update(newInstance)
            return newInstance
        }
    }

    private func initializeScheduler() async {
        logger?.trace("Scheduler is initialized")
        self.scheduler = WaitScheduler(resume: self.resumeWaiting)
    }

    private func resumeWaiting(instanceId: WorkflowInstanceID) async {
        logger?.trace("Resume waiting \(instanceId.debugDescription, privacy: .public)")

        guard let instance = try? await storage.instance(id: instanceId) else {
            return
        }

        do {
            guard let transitionState = instance.transitionState else {
                return
            }

            guard let workflow = await registry.workflow(id: instance.workflowId) else {
                throw Failure("Workflow not found for id: \(instance.workflowId)")
            }

            guard let transition = workflow.anyTransitions.first(where: { $0.id == transitionState.transitionId }) else {
                throw Failure("Transition not found for id: \(transitionState.transitionId)")
            }

            do {
                try await takeTransition(transition, on: instance, of: workflow)
            } catch {
                try await storage.update(
                    instance.transitionFailed(error, at: transition)
                )
            }
        } catch {
            logger?.error("Failed to resume \(instanceId, privacy: .public) with error \(error, privacy: .public)")
        }
    }
}
