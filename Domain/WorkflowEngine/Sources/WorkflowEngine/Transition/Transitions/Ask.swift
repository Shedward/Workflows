//
//  Ask.swift
//  WorkflowEngine
//
//  Created by Vlad Maltsev on 04.04.2026.
//

import Core

public typealias Prompt = String

public protocol Asking: TransitionProcess, DataBindable, Sendable, Defaultable {
    var prompt: Prompt? { get }
    func process() async throws
}

public extension Asking {
    var prompt: Prompt? { nil }

    func process() {
    }

    func start(context: inout WorkflowContext) async throws -> TransitionResult {
        if case .answered(let answers) = context.resume {
            try await runBody(in: &context, answers: answers, failures: failures) {
                try await $0.process()
            }
            return .completed
        }

        // Not answered yet: only the inputs are bound, so `prompt` can use them.
        var ask = self
        try Failure.wrap(failures.prepare) {
            try ask.bind(BindInputs(data: context.instance.data))
        }

        let expectedFields = ask.collectMetadata().asks.sortedByKey().map { field in
            Waiting.AskField(key: field.key, valueType: field.valueType)
        }

        return .waiting(.asking(.init(prompt: ask.prompt, expectedFields: expectedFields)))
    }
}

private extension Asking {
    var failures: BodyFailures {
        BodyFailures(
            prepare: "Failed to prepare ask \(type(of: self))",
            run: "Failed to process ask \(type(of: self))",
            finish: "Failed to finish ask \(type(of: self))"
        )
    }
}
