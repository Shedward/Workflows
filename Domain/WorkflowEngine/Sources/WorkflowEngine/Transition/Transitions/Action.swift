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

        try Failure.wrap("Failed to prepare to run action \(type(of: self))") {
            try action.bind(BindInputs(data: context.instance.data))
            try action.bind(CreateOutputStorage())
            try action.bind(SetDependencies(container: context.dependancyContainer))
        }

        let runningAction = action
        try await Failure.wrap("Failed to run action \(type(of: self))") {
            try await runningAction.run()
        }
        action = runningAction

        var readOutputs = ReadOutputs(data: context.instance.data)

        try Failure.wrap("Failed to finish action \(type(of: self))") {
            try action.bind(&readOutputs)
        }

        context.instance.data = readOutputs.data

        return .completed
    }
}
