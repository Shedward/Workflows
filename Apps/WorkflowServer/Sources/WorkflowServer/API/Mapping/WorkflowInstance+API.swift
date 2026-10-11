//
//  API+WorkflowInstance.swift
//  WorkflowServer
//
//  Created by Vlad Maltsev on 09.01.2026.
//

import API
import WorkflowEngine

extension API.WorkflowInstance {
    init(model: WorkflowEngine.WorkflowInstance) {
        self.init(
            id: model.id,
            workflowId: model.workflowId,
            state: model.state,
            transitionState: model.transitionState.map {
                API.TransitionState(model: $0)
            },
            data: API.WorkflowData(model: model.data),
            finishedAt: model.finishedAt
        )
    }
}
