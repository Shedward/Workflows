//
//  WorkflowState.swift
//  Workflow
//
//  Created by Vlad Maltsev on 24.12.2025.
//

public protocol WorkflowState: Sendable, RawRepresentable where RawValue == StateID {}

extension WorkflowState {
    public var id: StateID {
        rawValue
    }
}

public typealias StateID = String
