//
//  Workflows+Workflow.swift
//  Workflow
//
//  Created by Vlad Maltsev on 27.12.2025.
//

public extension Workflows {
    func workflows() async -> [AnyWorkflow] {
        await registry.allWorkflows()
    }

    func workflow(id: WorkflowID) async throws -> AnyWorkflow {
        guard let workflow = await registry.workflow(id: id) else {
            throw WorkflowsError.WorkflowNotFound(workflowId: id)
        }

        return workflow
    }
}
