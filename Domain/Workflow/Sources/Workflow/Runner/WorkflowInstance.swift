//
//  WorkflowRun.swift
//  Workflow
//
//  Created by Vlad Maltsev on 24.12.2025.
//

import Core

public struct WorkflowInstance: Sendable {
    public let id: WorkflowInstanceID
    public let workflowId: WorkflowID
    public let state: StateID

    init(id: WorkflowInstanceID, workflowId: WorkflowID, state: StateID) {
        self.id = id
        self.workflowId = workflowId
        self.state = state
    }
}

extension WorkflowInstance {
    public func withState(_ newState: StateID) -> Self {
        WorkflowInstance(id: id, workflowId: workflowId, state: newState)
    }
}

public typealias WorkflowInstanceID = String
