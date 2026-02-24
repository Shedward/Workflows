//
//  WorkflowInstance.swift
//  API
//
//  Created by Vlad Maltsev on 08.01.2026.
//

import Rest

public struct WorkflowInstance: JSONBody {
    public let id: String
    public let workflowId: String
    public let state: String
    public let transitionState: TransitionState?
    public let data: WorkflowData

    public init(
        id: String,
        workflowId: String,
        state: String,
        transitionState: TransitionState?,
        data: WorkflowData
    ) {
        self.id = id
        self.workflowId = workflowId
        self.state = state
        self.transitionState = transitionState
        self.data = data
    }
}
