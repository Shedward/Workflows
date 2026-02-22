//
//  WorkflowRegistry.swift
//  Workflow
//
//  Created by Vlad Maltsev on 26.12.2025.
//

import Core
import Foundation

public actor WorkflowRegistry: Sendable {
    private var workflows: [WorkflowID: AnyWorkflow] = [:]

    public init(_ workflows: [AnyWorkflow]) throws {
        self.workflows = .init(uniqueKeysWithValues: workflows.map { ($0.id, $0) })

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
        workflow(id: instance.workflowId)
    }

    public func workflow(id: WorkflowID) -> AnyWorkflow? {
        workflows[id]
    }

    public func allWorkflows() -> [AnyWorkflow] {
        Array(workflows.values.sorted(using: SortDescriptor(\.id, comparator: .lexical)))
    }
}
