//
//  Workflow+Mapping.swift
//  WorkflowServer
//
//  Created by Vlad Maltsev on 23.02.2026.
//

import API

extension API.Workflow {
    public init(model: WorkflowEngine.AnyWorkflow) {
        self.init(
            id: model.id,
            stateId: model.states,
            transitions: model.anyTransitions.map { transition in
                API.Transition(model: transition)
            }
        )
    }
}
