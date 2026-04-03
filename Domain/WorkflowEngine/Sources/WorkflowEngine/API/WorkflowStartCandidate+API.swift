//
//  WorkflowStartCandidate+API.swift
//  WorkflowEngine
//
//  Created by Claude on 03.04.2026.
//

import API

extension API.WorkflowStartCandidate {
    public init(model: WorkflowEngine.WorkflowStartCandidate) {
        self.init(
            id: model.id.uuidString,
            title: model.title,
            workflowId: model.workflowId,
            data: API.WorkflowData(model: model.data),
            inputs: model.inputs.map { API.DataField(model: $0) }
        )
    }
}
