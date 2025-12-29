//
//  TransitionInProgress.swift
//  Workflow
//
//  Created by Vlad Maltsev on 29.12.2025.
//

public struct TransitionInProgress: Sendable {
    public let transitionId: TransitionID
    public let lastResult: TransitionResult
}
