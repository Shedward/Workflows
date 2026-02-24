//
//  Transition+Mapping.swift
//  WorkflowServer
//
//  Created by Vlad Maltsev on 23.02.2026.
//

import API

extension API.Transition {
    public init(model: WorkflowEngine.AnyTransition) {
        self.init(
            processId: model.id.processId,
            fromState: model.id.from,
            toState: model.id.to,
            trigger: model.trigger.rawValue
        )
    }
}
