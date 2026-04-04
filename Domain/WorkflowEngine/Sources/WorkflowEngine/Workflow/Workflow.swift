//
//  Workflow.swift
//  Workflow
//
//  Created by Vlad Maltsev on 24.12.2025.
//

import Core

public protocol Workflow: AnyWorkflow, TransitionProcess, DataBindable, Defaultable {
    associatedtype State: WorkflowState

    var id: WorkflowID { get }
    var version: WorkflowVersion { get }

    @ArrayBuilder<Transition<State>>
    var transitions: Transitions { get }

    @ArrayBuilder<any WorkflowStartProvider>
    var providers: [any WorkflowStartProvider] { get }
}

extension Workflow {

    public typealias Transitions = [Transition<State>]

    public var id: WorkflowID {
        WorkflowID(describing: type(of: self))
    }

    public var states: [StateID] {
        State.allCases.map(\.id)
    }

    public var startId: StateID {
        State.start
    }

    public var finishId: StateID {
        State.finish
    }

    public var version: WorkflowVersion {
        1
    }

    public var providers: [any WorkflowStartProvider] {
        [ManualProvider()]
    }
}

public typealias WorkflowID = String
public typealias WorkflowVersion = Int
