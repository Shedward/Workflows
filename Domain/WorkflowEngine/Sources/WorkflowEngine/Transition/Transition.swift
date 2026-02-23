//
//  Transition.swift
//  Workflow
//
//  Created by Vlad Maltsev on 24.12.2025.
//

public struct Transition<State: WorkflowState>: AnyTransition, @unchecked Sendable {
    public let id: TransitionID
    public let from: StateID
    public let to: StateID
    public let process: TransitionProcess
    public let trigger: TransitionTrigger

    public init(
        from: StateID,
        to: StateID,
        process: TransitionProcess,
        workflow: AnyWorkflow,
        trigger: TransitionTrigger
    ) {
        self.id = TransitionID(from: from, to: to, processId: process.id, workflow: workflow.id)
        self.from = from
        self.to = to
        self.process = process
        self.trigger = trigger
    }
}

public struct TransitionID: Hashable, Sendable {
    public let from: StateID
    public let to: StateID
    public let processId: TransitionProcessID
    public let workflow: WorkflowID
}

extension TransitionID: CustomDebugStringConvertible {
    public var debugDescription: String {
        "\(workflow): \(from) -- \(processId) -> \(to)"
    }
}
