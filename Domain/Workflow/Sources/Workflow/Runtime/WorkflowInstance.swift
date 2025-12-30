//
//  WorkflowRun.swift
//  Workflow
//
//  Created by Vlad Maltsev on 24.12.2025.
//

import Core

public struct WorkflowInstance: Sendable {
    public var id: WorkflowInstanceID
    public var workflowId: WorkflowID
    public var state: StateID
    public var waitingTransition: TransitionWaiting?

    init(
        id: WorkflowInstanceID,
        workflowId: WorkflowID,
        state: StateID,
        waitingTransition: TransitionWaiting?
    ) {
        self.id = id
        self.workflowId = workflowId
        self.state = state
        self.waitingTransition = waitingTransition
    }
}

extension WorkflowInstance: Modifiers {
    public func moveToState(_ state: StateID) -> Self {
        with { $0.state = state }
    }

    public func waiting(_ waiting: Waiting, of transition: AnyTransition) -> Self {
        with { $0.waitingTransition = TransitionWaiting(transitionId: transition.id, waiting: waiting) }
    }

    public func endWaiting() -> Self {
        with { $0.waitingTransition = nil }
    }
}

public typealias WorkflowInstanceID = String

