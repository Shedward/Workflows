//
//  WorkflowRunner.swift
//  Workflow
//
//  Created by Vlad Maltsev on 30.12.2025.
//

import Core
import Foundation
import os

actor WorkflowRunner: WorkflowContext {
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
        let instances = try await storage.all()
        await scheduler?.rebuild(from: instances)
    }

    func start(_ workflow: AnyWorkflow) async throws -> WorkflowInstance {
        try await storage.create(workflow)
    }

    func takeTransition(_ transition: AnyTransition, on instance: WorkflowInstance, of workflow: AnyWorkflow) async throws {
        let result = try await transition.process.start(context: self)

        var nextInstance = instance
        await scheduler?.cancel(for: instance.id)

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
    }

    func finish(_ instance: WorkflowInstance) async throws {
        try await storage.finish(instance)
        await scheduler?.notifyFinished(instance.id)
    }

    // MARK: - Initialization helpers

    private func initializeScheduler() async {
        self.scheduler = WaitScheduler(resume: self.resumeWaiting)
    }

    // MARK: - Resuming helpers

    private func resumeWaiting(instanceId: WorkflowInstanceID) async {
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
            logger?.error("Failed to resume \(instanceId) with error \(error)")
        }
    }
}
