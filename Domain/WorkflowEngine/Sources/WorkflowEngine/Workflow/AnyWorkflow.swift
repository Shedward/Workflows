//
//  AnyWorkflow.swift
//  Workflow
//
//  Created by Vlad Maltsev on 26.12.2025.
//

public protocol AnyWorkflow: Sendable {
    var id: WorkflowID { get }
    var anyTransitions: [AnyTransition] { get }

    var states: [StateID] { get }
    var startId: StateID { get }
    var finishId: StateID { get }
}

extension Workflow {
    public var anyTransitions: [AnyTransition] {
        transitions.map { $0 }
    }
}
