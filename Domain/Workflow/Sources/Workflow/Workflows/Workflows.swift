//
//  Workflows.swift
//  Workflow
//
//  Created by Vlad Maltsev on 26.12.2025.
//

public actor Workflows {
    private let registry: WorkflowRegistry
    private let storage: WorkflowStorage

    public init(_ workflows: any Workflow...) throws {
        self.registry = try WorkflowRegistry(workflows)
        self.storage = InMemoryWorkflowStorage()
    }
}
