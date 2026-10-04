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

        return workflow.anyTransitions.filter { $0.from == instance.state }
    }

    @discardableResult
    public func takeTransition(processId: TransitionProcessID, on instance: WorkflowInstanceID) async throws -> WorkflowInstance {
        let instance = try await self.instance(id: instance)
        let workflow = try await self.workflow(id: instance.workflowId)

        let possibleTransitions = workflow.anyTransitions.filter { transition in
            instance.state == transition.from && transition.id.processId == processId
        }

        guard possibleTransitions.count == 1 else {
            throw WorkflowsError.TransitionProcessNotFoundForInstance(
                instance: instance.id,
                workflow: workflow.id,
                transitionId: processId,
                availableTransitions: workflow.anyTransitions.map(\.id)
            )
        }
        let transition = possibleTransitions[0]

        return try await runner.takeTransition(transition, on: instance.id, of: workflow)
    }

    @discardableResult
    public func answer(to instanceId: WorkflowInstanceID, data: WorkflowData) async throws -> WorkflowInstance {
        let instance = try await self.instance(id: instanceId)

        guard
            let transitionState = instance.transitionState,
            case .waiting(let waiting) = transitionState.state,
            case .asking = waiting
        else {
            throw WorkflowsError.InstanceNotAsking(instanceId: instanceId)
        }

        return try await runner.answerAsk(instanceId: instanceId, data: data)
    }
}
