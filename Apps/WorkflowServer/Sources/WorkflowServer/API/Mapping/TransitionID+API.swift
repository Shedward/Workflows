//
//  TransitionID.swift
//  WorkflowEngine
//
//  Created by Vlad Maltsev on 23.02.2026.
//

import API
import WorkflowEngine

extension API.TransitionID {
    init(model: WorkflowEngine.TransitionID) {
        self.init(
            workflow: model.workflow,
            processId: model.processId,
            from: model.from
        )
    }
}
