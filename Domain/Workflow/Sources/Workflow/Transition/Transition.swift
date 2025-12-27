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

    public var fromStateId: StateID {
        from.id
    }

    public var toStateId: StateID {
        to.id
    }

    public init(
        from: State,
        to: State,
        process: TransitionProcess,
        workflow: AnyWorkflow
    ) {
        self.id = TransitionID(from: from.id, to: to.id, processId: process.id, workflow: workflow.id)
        self.from = from
        self.to = to
        self.process = process
    }
}

public struct TransitionID: Hashable, Sendable {
    let from: StateID
    let to: StateID
    let processId: TransitionProcessID
    let workflow: WorkflowID
}

extension TransitionID: CustomDebugStringConvertible {
    public var debugDescription: String {
        "\(workflow): \(from) -- \(processId) -> \(to)"
    }
}
