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

    public init(dependencies: DependenciesContainer, _ workflows: any Workflow...) async throws {
        self.registry = try WorkflowRegistry(workflows)
        self.storage = InMemoryWorkflowStorage()
        self.runner = WorkflowRunner(
            storage: storage,
            registry: registry,
            dependencies: dependencies
        )
    }

    public func run() async throws {
        try await runner.resume()
    }
}
