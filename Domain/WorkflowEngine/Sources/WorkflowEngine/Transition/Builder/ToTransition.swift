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
        ToTransition(process: Self(), targets: [nextState.id])
    }

    static func toStart<State: WorkflowState>() -> ToTransition<State> {
        ToTransition(process: Self(), targets: [State.start])
    }

    static func toFinish<State: WorkflowState>() -> ToTransition<State> {
        ToTransition(process: Self(), targets: [State.finish])
    }
}
