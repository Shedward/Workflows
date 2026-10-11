//
//  Action.swift
//  Workflow
//
//  Created by Vlad Maltsev on 27.12.2025.
//

import Core

public protocol Action: TransitionProcess, DataBindable, Defaultable {
    func run() async throws
}

public extension Action {
    func start(context: inout WorkflowContext) async throws -> TransitionResult {
        try await runBody(in: &context, failures: failures) {
            try await $0.run()
        }
        return .completed
    }
}

private extension Action {
    var failures: BodyFailures {
        BodyFailures(
            prepare: "Failed to prepare to run action \(type(of: self))",
            run: "Failed to run action \(type(of: self))",
            finish: "Failed to finish action \(type(of: self))"
        )
    }
}
