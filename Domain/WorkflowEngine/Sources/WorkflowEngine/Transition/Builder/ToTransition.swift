//
//  ProcessToTransition.swift
//  Workflow
//
//  Created by Vlad Maltsev on 27.12.2025.
//

import Core

public struct ToTransition<State: WorkflowState> {
    public let process: TransitionProcess
    public let to: StateID

    public init(process: TransitionProcess, to: StateID) {
        self.process = process
        self.to = to
    }
}

public extension TransitionProcess {
    func to<State: WorkflowState>(_ nextState: State) -> ToTransition<State> {
        ToTransition(process: self, to: nextState.id)
    }

    func toStart<State: WorkflowState>() -> ToTransition<State> {
        ToTransition(process: self, to: State.start)
    }

    func toFinish<State: WorkflowState>() -> ToTransition<State> {
        ToTransition(process: self, to: State.finish)
    }
}

public extension TransitionProcess where Self: Defaultable {
    static func to<State: WorkflowState>(_ nextState: State) -> ToTransition<State> {
        ToTransition(process: Self(), to: nextState.id)
    }

    static func toStart<State: WorkflowState>() -> ToTransition<State> {
        ToTransition(process: Self(), to: State.start)
    }

    static func toFinish<State: WorkflowState>() -> ToTransition<State> {
        ToTransition(process: Self(), to: State.finish)
    }
}
