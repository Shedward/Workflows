//
//  WorkflowRun.swift
//  Workflow
//
//  Created by Vlad Maltsev on 24.12.2025.
//

public struct WorkflowInstance: Sendable {
    public var id: WorkflowInstanceID
    public var workflowId: WorkflowID
}

public typealias WorkflowInstanceID = String
