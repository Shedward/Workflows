//
//  Pass.swift
//  Workflow
//
//  Created by Vlad Maltsev on 29.12.2025.
//

import Core

public protocol Pass: TransitionProcess, Defaultable { }

public extension Pass where Self: TransitionProcess {
    func start(context: WorkflowContext) async throws -> TransitionState {
        return .completed
    }
}
