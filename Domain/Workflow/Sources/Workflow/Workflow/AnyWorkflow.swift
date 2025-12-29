//
//  AnyWorkflow.swift
//  Workflow
//
//  Created by Vlad Maltsev on 26.12.2025.
//

public protocol AnyWorkflow: Sendable {
    var id: WorkflowID { get }
    var initialState: StateID { get }
    var anyTransitions: [AnyTransition] { get }
}

extension Workflow {
    public var anyTransitions: [AnyTransition] {
        transitions.map { $0 }
    }
}
