//
//  ProcessToTransition.swift
//  Workflow
//
//  Created by Vlad Maltsev on 27.12.2025.
//

import Core

public struct ToTransition<State: WorkflowState> {
    public let process: TransitionProcess
    public let targets: [StateID]

    public init(process: TransitionProcess, targets: [StateID]) {
        self.process = process
        self.targets = targets
    }
}

public extension TransitionProcess {
    func to<State: WorkflowState>(_ nextState: State) -> ToTransition<State> {
        ToTransition(process: self, targets: [nextState.id])
    }

    func toStart<State: WorkflowState>() -> ToTransition<State> {
        ToTransition(process: self, targets: [State.start])
    }

    func toFinish<State: WorkflowState>() -> ToTransition<State> {
        ToTransition(process: self, targets: [State.finish])
    }
}

public extension TransitionProcess where Self: Defaultable {
    static func to<State: WorkflowState>(_ nextState: State) -> ToTransition<State> {
        Self().to(nextState)
    }

    static func toStart<State: WorkflowState>() -> ToTransition<State> {
        Self().toStart()
    }

    static func toFinish<State: WorkflowState>() -> ToTransition<State> {
        Self().toFinish()
    }
}
