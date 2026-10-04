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

public extension Action where Self: TransitionProcess {
    func start(context: inout WorkflowContext) async throws -> TransitionResult {
        try await withBoundData(in: &context, kind: "action", prepareVerb: "prepare to run") {
            try await $0.run()
        }
        return .completed
    }
}
