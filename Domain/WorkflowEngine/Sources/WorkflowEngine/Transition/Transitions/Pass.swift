//
//  Pass.swift
//  Workflow
//
//  Created by Vlad Maltsev on 29.12.2025.
//

import Core

public protocol Pass: TransitionProcess, Defaultable { }

public extension Pass {
    func start(context: inout WorkflowContext) -> TransitionResult {
        return .completed
    }
}
