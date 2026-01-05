//
//  Workflow+Start.swift
//  Workflow
//
//  Created by Vlad Maltsev on 27.12.2025.
//

public extension Workflows {
    func start(_ workflow: AnyWorkflow, initialData: WorkflowData = .init()) async throws -> WorkflowInstance {
        try await runner.start(workflow, initialData: initialData)
    }

    func start(_ workflowId: WorkflowID, initialData: WorkflowData = .init()) async throws -> WorkflowInstance {
        let workflow = try await workflow(id: workflowId)
        return try await start(workflow, initialData: initialData)
    }
}
