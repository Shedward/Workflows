//
//  Workflow.swift
//  Workflow
//
//  Created by Vlad Maltsev on 24.12.2025.
//

import Core

public protocol Workflow: AnyWorkflow, TransitionProcess {
    associatedtype State: WorkflowState

    var id: WorkflowID { get }
    var version: WorkflowVersion { get }

    @ArrayBuilder<Transition<State>>
    var transitions: Transitions { get }
}

extension Workflow {

    public typealias Transitions = [Transition<State>]

    public var id: WorkflowID {
        WorkflowID(describing: type(of: self))
    }

    public var initialState: StateID {
        State.initial.id
    }

    public var version: WorkflowVersion {
        1
    }
}

public typealias WorkflowID = String
public typealias WorkflowVersion = Int
