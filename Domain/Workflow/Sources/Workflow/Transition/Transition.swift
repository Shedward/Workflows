//
//  Transition.swift
//  Workflow
//
//  Created by Vlad Maltsev on 24.12.2025.
//

public struct Transition<State: WorkflowState>: AnyTransition {
    public let id: TransitionID
    public let from: State
    public let to: State
    public let process: TransitionProcess

    public init(
        from: State,
        to: State,
        process: TransitionProcess,
    ) {
        self.id = TransitionID(from: from.id, to: to.id, processId: process.id)
        self.from = from
        self.to = to
        self.process = process
    }
}

public struct TransitionID: Hashable {
    let from: StateID
    let to: StateID
    let processId: TransitionProcessID
}

extension TransitionID: CustomDebugStringConvertible {
    public var debugDescription: String {
        "\(from) -- \(processId) -> \(to)"
    }
}
