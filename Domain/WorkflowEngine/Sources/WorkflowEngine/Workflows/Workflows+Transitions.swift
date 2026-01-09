//
//  Workflow+Transitions.swift
//  Workflow
//
//  Created by Vlad Maltsev on 28.12.2025.
//

extension Workflows {
    public func transitions(for instanceId: WorkflowInstanceID) async throws -> [AnyTransition] {
        let instance = try await instance(id: instanceId)
        let workflow = try await workflow(id: instance.workflowId)

        return workflow.anyTransitions.filter { $0.fromStateId == instance.state }
    }

    public func transition(id: TransitionID) async throws -> AnyTransition {
        let workflow = try await workflow(id: id.workflow)

        guard let transition = workflow.anyTransitions.first(where: { $0.id == id }) else {
            throw WorkflowsError.TransitionNotFound(transitionId: id)
        }

        return transition
    }

    @discardableResult
    public func takeTransition(id transitionId: TransitionID, on instance: WorkflowInstanceID) async throws -> WorkflowInstance {
        let transition = try await self.transition(id: transitionId)
        let instance = try await self.instance(id: instance)
        let workflow = try await self.workflow(id: transitionId.workflow)

        guard instance.workflowId == transitionId.workflow else {
            throw WorkflowsError.WorkflowInstanceMismatch(instance: transition.id.workflow, found: instance.workflowId)
        }

        return try await runner.takeTransition(transition, on: instance, of: workflow)
    }

    @discardableResult
    public func takeTransition(processId: TransitionProcessID, on instance: WorkflowInstanceID) async throws -> WorkflowInstance {
        let instance = try await self.instance(id: instance)
        let workflow = try await self.workflow(id: instance.workflowId)

        let possibleTransitions = workflow.anyTransitions.filter { transition in
            instance.state == transition.fromStateId && transition.id.processId == processId
        }

        guard possibleTransitions.count == 1 else {
            throw WorkflowsError.TransitionProcessNotFoundForInstance(
                instance: instance.id,
                workflow: workflow.id,
                transitionId: processId
            )
        }
        let transition = possibleTransitions[0]

        return try await runner.takeTransition(transition, on: instance, of: workflow)
    }
}
