//
//  ProcessToTransition.swift
//  Workflow
//
//  Created by Vlad Maltsev on 27.12.2025.
//

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
}
