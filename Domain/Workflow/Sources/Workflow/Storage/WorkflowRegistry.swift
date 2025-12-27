//
//  WorkflowRegistry.swift
//  Workflow
//
//  Created by Vlad Maltsev on 26.12.2025.
//

import Core

public final class WorkflowRegistry {
    private var workflows: [WorkflowID: AnyWorkflow] = [:]

    public init(_ workflows: [AnyWorkflow]) throws {
        workflows.forEach(register)

        if workflows.count != self.workflows.count {
            let ids = workflows.map(\.id)
            let registeredIds = self.workflows.keys
            throw Failure("Failed to register workflows. Expected \(ids), registered: \(registeredIds)")
        }
    }

    public func register(_ workflow: AnyWorkflow) {
        self.workflows[workflow.id] = workflow
    }

    public func workflow(instance: WorkflowInstance) -> AnyWorkflow? {
        self.workflows[instance.workflowId]
    }
}
