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
    public var transitionState: TransitionState?

    init(
        id: WorkflowInstanceID,
        workflowId: WorkflowID,
        state: StateID,
        transitionState: TransitionState?
    ) {
        self.id = id
        self.workflowId = workflowId
        self.state = state
        self.transitionState = transitionState
    }
}

extension WorkflowInstance: Modifiers {
    public func moveToState(_ state: StateID) -> Self {
        with { $0.state = state }
    }

    public func transitionWaiting(_ waiting: Waiting, of transition: AnyTransition) -> Self {
        with { $0.transitionState = TransitionState(transitionId: transition.id, state: .waiting(waiting)) }
    }

    public func transitionFailed(_ error: Error, at transition: AnyTransition) -> Self {
        with { $0.transitionState = TransitionState(transitionId: transition.id, state: .failed(error)) }
    }

    public func transitionEnded() -> Self {
        with { $0.transitionState = nil }
    }
}

public typealias WorkflowInstanceID = String

