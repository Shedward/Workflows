//
//  TransitionRunState.swift
//
//
//  Created by Vlad Maltsev on 13.01.2024.
//

public enum TransitionStepState: Codable {
    case notStarted
    case finished
    case failed
}

public struct TransitionRunState: Codable {
    public var stateByStep: [TransitionStep.ID: TransitionStepState]
    
    public init() {
        self.stateByStep = [:]
    }
}
