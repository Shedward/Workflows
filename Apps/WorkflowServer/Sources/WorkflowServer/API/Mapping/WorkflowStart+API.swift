//
//  WorkflowStart+API.swift
//  WorkflowEngine
//

import API
import WorkflowEngine

extension API.WorkflowStart {
    init(model: WorkflowEngine.WorkflowStart, workflowId: WorkflowID) {
        self.init(
            workflowId: workflowId,
            title: model.title,
            data: API.WorkflowData(model: model.data)
        )
    }
}
