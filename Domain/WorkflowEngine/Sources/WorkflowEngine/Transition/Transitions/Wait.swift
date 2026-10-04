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

public extension Wait where Self: TransitionProcess {
    func start(context: inout WorkflowContext) async throws -> TransitionResult {
        let nextTime = try await withBoundData(in: &context, kind: "waiting") {
            try await $0.resume()
        }

        if let nextTime {
            return .waiting(.time(nextTime))
        } else {
            return .completed
        }
    }
}
