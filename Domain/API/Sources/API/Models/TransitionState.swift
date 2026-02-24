//
//  TransitionState.swift
//  API
//
//  Created by Vlad Maltsev on 23.02.2026.
//

import Core
import Foundation
import Rest

public struct TransitionState: JSONBody {
    public let id: TransitionID
    public let state: State

    public init(id: TransitionID, state: State) {
        self.id = id
        self.state = state
    }
}

extension TransitionState {
    public enum State: JSONBody {
        case waitingTime(date: Date)
        case waitingWorkflow(workflowId: String)
        case failed(error: ErrorDescription)
    }
}
