//
//  WorkflowContext.swift
//  Workflow
//
//  Created by Vlad Maltsev on 30.12.2025.
//

public protocol WorkflowContext: Sendable {
    func start(_ workflow: AnyWorkflow) async throws -> WorkflowInstance
}
