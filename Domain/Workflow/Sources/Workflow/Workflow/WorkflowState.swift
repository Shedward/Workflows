//
//  WorkflowState.swift
//  Workflow
//
//  Created by Vlad Maltsev on 24.12.2025.
//

public protocol WorkflowState: Sendable, RawRepresentable, CaseIterable where RawValue == StateID {
    static var initial: Self { get }
    static var final: Self { get }
}

extension WorkflowState {
    public var id: StateID {
        rawValue
    }
}

public typealias StateID = String
