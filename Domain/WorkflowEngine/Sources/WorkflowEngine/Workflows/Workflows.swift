//
//  Workflows.swift
//  Workflow
//
//  Created by Vlad Maltsev on 26.12.2025.
//

import Core

public enum ValidationMode: Sendable {
    case strict
    case lenient
}

public actor Workflows {
    let registry: WorkflowRegistry
    let storage: WorkflowStorage
    let runner: WorkflowRunner

    public init(
        storage: WorkflowStorage = InMemoryWorkflowStorage(),
        dependencies: DependenciesContainer,
        validation: ValidationMode = .lenient,
        @ArrayBuilder<any Workflow> workflows: () -> [any Workflow]
    ) async throws {
        self.registry = try WorkflowRegistry(workflows())
        self.storage = storage
        self.runner = WorkflowRunner(
            storage: storage,
            registry: registry,
            dependencies: dependencies
        )

        try await registry.validateAll(dependencies: dependencies, mode: validation)
    }

    public func run() async throws {
        try await runner.resume()
    }

    public func graph(for workflowId: WorkflowID) async -> WorkflowGraph? {
        await registry.graph(for: workflowId)
    }
}
