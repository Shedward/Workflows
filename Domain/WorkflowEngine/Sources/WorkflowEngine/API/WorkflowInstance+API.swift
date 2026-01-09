//
//  API+WorkflowInstance.swift
//  WorkflowEngine
//
//  Created by Vlad Maltsev on 09.01.2026.
//

import API

extension API.WorkflowInstance {
    public init(model: WorkflowInstance) throws {
        self.init(
            id: model.id,
            workflowId: model.workflowId,
            state: model.state,
            data: try API.WorkflowData(model: model.data)
        )
    }
}
