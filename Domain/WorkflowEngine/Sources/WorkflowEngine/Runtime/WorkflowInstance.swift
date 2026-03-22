//
//  WorkflowRun.swift
//  Workflow
//
//  Created by Vlad Maltsev on 24.12.2025.
//

import Core
import Foundation

public struct WorkflowInstance: Sendable {
    public var id: WorkflowInstanceID
    public var workflowId: WorkflowID
    public var state: StateID
    public var transitionState: TransitionState?
    public var data: WorkflowData
    public var finishedAt: Date?

    init(
        id: WorkflowInstanceID,
        workflowId: WorkflowID,
        state: StateID,
        transitionState: TransitionState?,
        data: WorkflowData,
        finishedAt: Date? = nil
    ) {
        self.id = id
        self.workflowId = workflowId
        self.state = state
        self.transitionState = transitionState
        self.data = data
        self.finishedAt = finishedAt
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

    public func transitionExecuting(_ transition: AnyTransition) -> Self {
        with { $0.transitionState = TransitionState(transitionId: transition.id, state: .executing) }
    }

    public func transitionEnded() -> Self {
        with { $0.transitionState = nil }
    }

    public func data(_ data: WorkflowData) -> Self {
        with { $0.data = data }
    }
}

public typealias WorkflowInstanceID = String

