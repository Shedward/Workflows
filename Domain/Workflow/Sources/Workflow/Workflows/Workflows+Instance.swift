//
//  Workflows+Transitions.swift
//  Workflow
//
//  Created by Vlad Maltsev on 27.12.2025.
//

import Core

public extension Workflows {
    func instance(id: WorkflowInstanceID) async throws -> WorkflowInstance {
        guard let instance = try await storage.instance(id: id) else {
            throw WorkflowsError.WorkflowInstanceNotFound(instanceId: id)
        }
        
        return instance
    }

    func transitions(for instanceId: WorkflowInstanceID) async throws -> [AnyTransition] {
        let instance = try await instance(id: instanceId)
        let workflow = try await workflow(id: instance.workflowId)

        return workflow.anyTransitions.filter { $0.fromStateId == instance.state }
    }

    func startTransition(_ transitionId: TransitionID, instance: WorkflowInstanceID) async throws {
        let workflow = try await workflow(id: transitionId.workflow)

        guard let transition = workflow.anyTransitions.first(where: { $0.id == transitionId }) else {
            throw WorkflowsError.TransitionNotFound(transitionId: transitionId)
        }

        guard let instance = try await storage.instance(id: instance) else {
            throw WorkflowsError.WorkflowInstanceNotFound(instanceId: instance)
        }

        guard instance.workflowId == transitionId.workflow else {
            throw WorkflowsError.WorkflowInstanceMismatch(instance: transition.id.workflow, found: instance.workflowId)
        }

        let result = try await transition.process.start()
        switch result {
        case .completed:
            try await storage.update(instance.withState(transition.toStateId))
        }
    }
}
