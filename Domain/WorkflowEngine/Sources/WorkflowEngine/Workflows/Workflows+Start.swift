//
//  Workflow+Start.swift
//  Workflow
//
//  Created by Vlad Maltsev on 27.12.2025.
//

public extension Workflows {
    func create(_ workflowId: WorkflowID, initialData: WorkflowData = .init()) async throws -> WorkflowInstance {
        let workflow = try await workflow(id: workflowId)
        return try await runner.create(workflow, initialData: initialData)
    }

    func start(_ workflow: AnyWorkflow, initialData: WorkflowData = .init()) async throws -> WorkflowInstance {
        try await runner.start(workflow, initialData: initialData)
    }

    func start(_ workflowId: WorkflowID, initialData: WorkflowData = .init()) async throws -> WorkflowInstance {
        let workflow = try await workflow(id: workflowId)
        return try await start(workflow, initialData: initialData)
    }

    func runAutomaticTransitions(on instanceId: WorkflowInstanceID) async throws -> WorkflowInstance {
        guard let instance = try await storage.instance(id: instanceId) else {
            throw WorkflowsError.WorkflowInstanceNotFound(instanceId: instanceId)
        }
        return await runner.runAutomaticTransitions(from: instance)
    }
}
