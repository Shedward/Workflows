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
        var action = self

        try action.bind(BindInputs(data: context.data))
        try action.bind(CreateOutputStorage())
        try await action.run()

        var readOutputs = ReadOutputs(data: context.data)
        try action.bind(&readOutputs)
        context.data = readOutputs.data

        return .completed
    }
}
