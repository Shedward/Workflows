//
//  Workflow+Start.swift
//  Workflow
//
//  Created by Vlad Maltsev on 27.12.2025.
//

public extension Workflows {
    func start(_ workflow: AnyWorkflow) async throws -> WorkflowInstance {
        let instance = try await storage.create(workflow)
        return instance
    }

    func start(_ workflowId: WorkflowID) async throws -> WorkflowInstance {
        let workflow = try await workflow(id: workflowId)
        return try await start(workflow)
    }
}
