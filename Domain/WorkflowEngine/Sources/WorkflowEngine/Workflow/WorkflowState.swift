//
//  State.swift
//  Workflow
//
//  Created by Vlad Maltsev on 24.12.2025.
//

public protocol WorkflowState: Sendable, RawRepresentable, CaseIterable where RawValue == StateID {
}

extension WorkflowState {
    public var id: StateID {
        rawValue
    }

    public static var start: StateID  {
        "_start"
    }

    public static var finish: StateID {
        "_finish"
    }
}

public typealias StateID = String
