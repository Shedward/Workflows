//
//  TransitionState+API.swift
//  WorkflowEngine
//
//  Created by Vlad Maltsev on 24.02.2026.
//

import API

extension API.TransitionState {
    init(model: WorkflowEngine.TransitionState) {
        self.init(
            id: API.TransitionID(model: model.transitionId),
            state: API.TransitionState.State(model: model.state)
        )
    }
}

extension API.TransitionState.State {
    init(model: WorkflowEngine.TransitionState.State) {
        switch model {
        case .executing:
            self = .executing
        case .failed(let error):
            self = .failed(error: ErrorDescription(error: error))
        case .waiting(.time(let time)):
            self = .waitingTime(date: time.date)
        case .waiting(.workflowFinished(let finished)):
            self = .waitingWorkflow(workflowId: finished.instanceId)
        case .waiting(.asking(let asking)):
            self = .asking(
                prompt: asking.prompt,
                expectedFields: asking.expectedFields.map {
                    API.TransitionState.AskField(key: $0.key, valueType: $0.valueType)
                }
            )
        }
    }
}
