//
//  Wait.swift
//  Workflow
//
//  Created by Vlad Maltsev on 29.12.2025.
//

import Foundation

public protocol Wait: TransitionProcess, DataBindable {
    func resume() async throws -> Waiting.Time?
}

public extension Wait where Self: TransitionProcess {
    func start(context: inout WorkflowContext) async throws -> TransitionResult {
        var wait = self

        try wait.bind(BindInputs(data: context.data))
        try wait.bind(CreateOutputStorage())

        let nextTime = try await wait.resume()

        var readOutputs = ReadOutputs(data: context.data)
        try wait.bind(&readOutputs)
        context.data = readOutputs.data

        if let nextTime {
            return .waiting(.time(nextTime))
        } else {
            return .completed
        }
    }
}
