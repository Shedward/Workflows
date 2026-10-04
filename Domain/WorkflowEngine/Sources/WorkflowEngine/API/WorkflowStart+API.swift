//
//  WorkflowStart+API.swift
//  WorkflowEngine
//

import API

extension API.WorkflowStart {
    public init(model: WorkflowEngine.WorkflowStart, workflowId: WorkflowID) {
        self.init(
            workflowId: workflowId,
            title: model.title,
            data: API.WorkflowData(model: model.data)
        )
    }
}
