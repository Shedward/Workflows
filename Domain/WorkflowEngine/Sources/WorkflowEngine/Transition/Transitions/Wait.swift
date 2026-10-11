//
//  Wait.swift
//  Workflow
//
//  Created by Vlad Maltsev on 29.12.2025.
//

import Foundation

public protocol Wait: TransitionProcess, DataBindable, Sendable, Defaultable {
    func resume() async throws -> Waiting.Time?
}

public extension Wait {
    func start(context: inout WorkflowContext) async throws -> TransitionResult {
        let nextTime = try await runBody(in: &context, failures: failures) {
            try await $0.resume()
        }

        if let nextTime {
            return .waiting(.time(nextTime))
        } else {
            return .completed
        }
    }
}

private extension Wait {
    var failures: BodyFailures {
        BodyFailures(
            prepare: "Failed to prepare waiting \(type(of: self))",
            run: "Failed to run waiting \(type(of: self))",
            finish: "Failed to finish waiting \(type(of: self))"
        )
    }
}
