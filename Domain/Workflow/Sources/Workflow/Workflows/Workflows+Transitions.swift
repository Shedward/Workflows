//
//  Workflow+Transitions.swift
//  Workflow
//
//  Created by Vlad Maltsev on 28.12.2025.
//

extension Workflows {
    func transitions(for instanceId: WorkflowInstanceID) async throws -> [AnyTransition] {
        let instance = try await instance(id: instanceId)
        let workflow = try await workflow(id: instance.workflowId)

        return workflow.anyTransitions.filter { $0.fromStateId == instance.state }
    }

    func transition(id: TransitionID) async throws -> AnyTransition {
        let workflow = try await workflow(id: id.workflow)

        guard let transition = workflow.anyTransitions.first(where: { $0.id == id }) else {
            throw WorkflowsError.TransitionNotFound(transitionId: id)
        }

        return transition
    }

    func takeTransition(id transitionId: TransitionID, on instance: WorkflowInstanceID) async throws {
        let transition = try await self.transition(id: transitionId)
        let instance = try await self.instance(id: instance)
        let workflow = try await self.workflow(id: transitionId.workflow)

        guard instance.workflowId == transitionId.workflow else {
            throw WorkflowsError.WorkflowInstanceMismatch(instance: transition.id.workflow, found: instance.workflowId)
        }

        try await runner.takeTransition(transition, on: instance, of: workflow)
    }
}
