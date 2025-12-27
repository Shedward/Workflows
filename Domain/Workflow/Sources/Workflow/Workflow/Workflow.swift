//
//  Workflow.swift
//  Workflow
//
//  Created by Vlad Maltsev on 24.12.2025.
//

import Core

public protocol Workflow: AnyWorkflow {
    associatedtype State: WorkflowState

    var id: WorkflowID { get }
    var version: WorkflowVersion { get }

    @ArrayBuilder<Transition<State>>
    var transitions: [Transition<State>] { get }
}

extension Workflow {

    public var id: WorkflowID {
        WorkflowID(describing: type(of: self))
    }

    public var version: WorkflowVersion {
        1
    }
}

public typealias WorkflowID = String
public typealias WorkflowVersion = Int
