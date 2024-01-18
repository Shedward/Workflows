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

public final class TransitionRunState: Codable {
    private var stateByStep: [TransitionStep.ID: TransitionStepState]
    
    public init() {
        self.stateByStep = [:]
    }
    
    public func registerStep(_ step: TransitionStep) {
        if stateByStep[step.id] != .finished {
            stateByStep[step.id] = .notStarted
        }
    }
    
    public func shouldRun(_ step: TransitionStep) -> Bool {
        return stateByStep[step.id] != .finished
    }
    
    public func finished(_ step: TransitionStep) {
        stateByStep[step.id] = .finished
    }
    
    public func failed(_ step: TransitionStep) {
        stateByStep[step.id] = .failed
    }
}
