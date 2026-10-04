//
//  Workflow+API.swift
//  WorkflowServer
//
//  Created by Vlad Maltsev on 23.02.2026.
//

import API
import WorkflowEngine

extension API.Workflow {
    init(model: WorkflowEngine.AnyWorkflow) {
        self.init(
            id: model.id,
            stateId: model.states,
            transitions: model.anyTransitions.map { transition in
                API.Transition(model: transition)
            }
        )
    }
}
