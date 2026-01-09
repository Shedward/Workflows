//
//  Workflows.swift
//  Workflow
//
//  Created by Vlad Maltsev on 26.12.2025.
//

public actor Workflows {
    let registry: WorkflowRegistry
    let storage: WorkflowStorage
    let runner: WorkflowRunner

    public init(_ workflows: any Workflow...) async throws {
        self.registry = try await WorkflowRegistry(workflows)
        self.storage = InMemoryWorkflowStorage()
        self.runner = WorkflowRunner(storage: storage, registry: registry)

        try await runner.resume()
    }
}
