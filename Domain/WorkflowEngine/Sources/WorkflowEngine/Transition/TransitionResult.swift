//
//  TransitionState.swift
//  Workflow
//
//  Created by Vlad Maltsev on 26.12.2025.
//

public enum TransitionResult: Sendable {
    case completed
    case waiting(Waiting)
}
