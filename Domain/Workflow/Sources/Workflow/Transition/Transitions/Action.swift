//
//  Action.swift
//  Workflow
//
//  Created by Vlad Maltsev on 27.12.2025.
//

import Core

public protocol Action: TransitionProcess, Defaultable {
    func run() async throws
}

public extension Action where Self: TransitionProcess {
    func start(context: WorkflowContext) async throws -> TransitionResult {
        try await run()
        return .completed
    }
}
