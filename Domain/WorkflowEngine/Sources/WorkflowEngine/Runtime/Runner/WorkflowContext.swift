//
//  WorkflowContext.swift
//  Workflow
//
//  Created by Vlad Maltsev on 30.12.2025.
//

public struct WorkflowContext: Sendable {
    var data: WorkflowData
    let start: @Sendable (_ workflow: AnyWorkflow, _ initialData: WorkflowData) async throws -> WorkflowInstance
}
