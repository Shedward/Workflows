//
//  WorkflowRunner.swift
//  Workflow
//
//  Created by Vlad Maltsev on 30.12.2025.
//

import Core
import Foundation

actor WorkflowRunner: WorkflowContext {
    private let storage: WorkflowStorage
    private let registry: WorkflowRegistry

    private var lastDeadline: DispatchTime = .now()
    private let timer = DispatchSource.makeTimerSource()

    init(storage: WorkflowStorage, registry: WorkflowRegistry) {
        self.storage = storage
        self.registry = registry
    }

    func resume() async throws {
        timer.setEventHandler { [weak self] in
            guard let self else { return }
            Task {
                try await self.resumeWaitingForTime()
            }
        }

        self.scheduleNextCheck()
    }

    func start(_ workflow: AnyWorkflow) async throws -> WorkflowInstance {
        let instance = try await storage.create(workflow)
        return instance
    }

    func takeTransition(_ transition: AnyTransition, on instance: WorkflowInstance, of workflow: AnyWorkflow) async throws {
        let result = try await transition.process.start(context: self)

        let nextInstance: WorkflowInstance

        switch result {
        case .completed:
            nextInstance = instance
                .endWaiting()
                .moveToState(transition.toStateId)
        case .waiting(let waiting):
            nextInstance = instance
                .waiting(waiting, of: transition)
            scheduleNextCheck(waiting)
        }

        if nextInstance.state == workflow.finalState {
            try await finish(nextInstance)
        } else {
            try await storage.update(nextInstance)
        }
    }

    func finish(_ instance: WorkflowInstance) async throws {
        try await storage.finish(instance)
        try await resumeWaitingForFinishing(of: instance)
    }

    func scheduleNextCheck(_ waiting: Waiting? = nil) {
        let deadline: DispatchTime
        if case .time(let time) = waiting {
            let nanoseconds = max(0, Int(time.date.timeIntervalSinceNow * 1_000_000_000))
            deadline = .now() + .nanoseconds(nanoseconds)
        } else {
            deadline = .now()
        }

        timer.schedule(deadline: deadline)
        timer.resume()
    }

    private func resumeWaitingForTime() async throws {
        let allInstances = try await storage.all()
        for waitingInstance in allInstances {
            if case .time = waitingInstance.waitingTransition?.waiting{
                try await resumeWaiting(waitingInstance)
            }
        }
    }

    private func resumeWaitingForFinishing(of finishingInstance: WorkflowInstance) async throws {
        let allInstances = try await storage.all()
        for waitingInstance in allInstances {
            if case .workflowFinished(let finished) = waitingInstance.waitingTransition?.waiting, finished.instanceId == finishingInstance.id {
                try await resumeWaiting(waitingInstance)
            }
        }
    }

    private func resumeWaiting(_ instance: WorkflowInstance) async throws {
        guard let waitingTransition = instance.waitingTransition else {
            return
        }

        guard let workflow = await registry.workflow(instance: instance) else {
            throw Failure("Workflow not found for id: \(instance.id)")
        }

        guard let transition = workflow.anyTransitions.first(where: { $0.id == waitingTransition.transitionId }) else {
            throw Failure("Transition not found for id: \(waitingTransition)")
        }

        try await takeTransition(transition, on: instance, of: workflow)
    }
}
