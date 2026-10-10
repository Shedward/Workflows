//
//  WorkflowInstance.swift
//  Workflow
//
//  Created by Vlad Maltsev on 24.12.2025.
//

import Core
import Foundation

public struct WorkflowInstance: Sendable, Codable {
    public var id: WorkflowInstanceID
    public var workflowId: WorkflowID
    public var workflowVersion: WorkflowVersion
    public var state: StateID
    public var transitionState: TransitionState?
    public var data: WorkflowData
    public var finishedAt: Date?

    init(
        id: WorkflowInstanceID,
        workflowId: WorkflowID,
        workflowVersion: WorkflowVersion,
        state: StateID,
        transitionState: TransitionState?,
        data: WorkflowData,
        finishedAt: Date? = nil
    ) {
        self.id = id
        self.workflowId = workflowId
        self.workflowVersion = workflowVersion
        self.state = state
        self.transitionState = transitionState
        self.data = data
        self.finishedAt = finishedAt
    }

    init(atStartOf workflow: AnyWorkflow, data: WorkflowData) {
        self.init(
            id: UUID().uuidString,
            workflowId: workflow.id,
            workflowVersion: workflow.version,
            state: workflow.startId,
            transitionState: nil,
            data: data
        )
    }
}

extension WorkflowInstance: Modifiers {
    public func finished(at date: Date) -> Self {
        with { $0.finishedAt = date }
    }

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
