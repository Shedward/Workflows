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
}

public extension Asking where Self: TransitionProcess {
    func start(context: inout WorkflowContext) async throws -> TransitionResult {
        var ask = self

        try Failure.wrap("Failed to prepare ask \(type(of: self))") {
            try ask.bind(BindInputs(data: context.instance.data))
        }

        if case .answered(let userData) = context.resume {
            try Failure.wrap("Failed to prepare ask \(type(of: self))") {
                try ask.bind(CreateOutputStorage())
                try ask.bind(BindAskInputs(data: userData))
                try ask.bind(SetDependencies(container: context.dependancyContainer))
            }

            let runningAsk = ask
            try await Failure.wrap("Failed to process ask \(type(of: self))") {
                try await runningAsk.process()
            }
            ask = runningAsk

            var readOutputs = ReadOutputs(data: context.instance.data)

            try Failure.wrap("Failed to finish ask \(type(of: self))") {
                try ask.bind(&readOutputs)
            }
            context.instance.data = readOutputs.data

            return .completed
        }

        let metadata = ask.collectMetadata()
        let expectedFields = metadata.asks.map { field in
            Waiting.AskField(key: field.key, valueType: field.valueType)
        }

        return .waiting(.asking(.init(prompt: ask.prompt, expectedFields: expectedFields)))
    }
}
