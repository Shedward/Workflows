//
//  TransitionInProgress.swift
//  Workflow
//
//  Created by Vlad Maltsev on 29.12.2025.
//

public struct TransitionState: Sendable {
    public let transitionId: TransitionID
    public let state: State
}

extension TransitionState {
    public enum State: Sendable {
        case waiting(Waiting)
        case failed(Error)
    }
}
