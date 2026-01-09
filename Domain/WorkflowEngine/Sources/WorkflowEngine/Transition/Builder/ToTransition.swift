//
//  ProcessToTransition.swift
//  Workflow
//
//  Created by Vlad Maltsev on 27.12.2025.
//

import Core

public struct ToTransition<State: WorkflowState> {
    public let process: TransitionProcess
    public let to: State

    public init(process: TransitionProcess, to: State) {
        self.process = process
        self.to = to
    }
}

public extension TransitionProcess {
    func to<State: WorkflowState>(_ nextState: State) -> ToTransition<State> {
        ToTransition(process: self, to: nextState)
    }

    func toInitial<State: WorkflowState>() -> ToTransition<State> {
        ToTransition(process: self, to: .initial)
    }

    func toFinish<State: WorkflowState>() -> ToTransition<State> {
        ToTransition(process: self, to: .final)
    }
}

public extension TransitionProcess where Self: Defaultable {
    static func to<State: WorkflowState>(_ nextState: State) -> ToTransition<State> {
        ToTransition(process: Self(), to: nextState)
    }

    static func toInitial<State: WorkflowState>() -> ToTransition<State> {
        ToTransition(process: Self(), to: .initial)
    }

    static func toFinish<State: WorkflowState>() -> ToTransition<State> {
        ToTransition(process: Self(), to: .final)
    }
}
