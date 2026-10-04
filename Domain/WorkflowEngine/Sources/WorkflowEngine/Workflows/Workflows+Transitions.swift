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
        try await runner.takeTransition(processId: processId, on: instance)
    }

    @discardableResult
    public func answer(to instanceId: WorkflowInstanceID, data: WorkflowData) async throws -> WorkflowInstance {
        try await runner.answerAsk(instanceId: instanceId, data: data)
    }
}
