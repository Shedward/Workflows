//
//  WorkflowContext.swift
//  Workflow
//
//  Created by Vlad Maltsev on 30.12.2025.
//

public struct WorkflowContext: Sendable {
    let start: @Sendable (_ workflow: AnyWorkflow) async throws -> WorkflowInstance
}
