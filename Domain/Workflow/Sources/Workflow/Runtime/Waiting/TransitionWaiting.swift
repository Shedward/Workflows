//
//  TransitionInProgress.swift
//  Workflow
//
//  Created by Vlad Maltsev on 29.12.2025.
//

public struct TransitionWaiting: Sendable {
    public let transitionId: TransitionID
    public let waiting: Waiting
}
