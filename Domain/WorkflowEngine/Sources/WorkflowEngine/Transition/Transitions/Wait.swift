//
//  Wait.swift
//  Workflow
//
//  Created by Vlad Maltsev on 29.12.2025.
//

import Foundation

public protocol Wait: TransitionProcess, DataBindable, Sendable {
    func resume() async throws -> Waiting.Time?
}

public extension Wait where Self: TransitionProcess {
    func start(context: inout WorkflowContext) async throws -> TransitionResult {
        var wait = self

        try Failure.wrap("Failed to prepare waiting \(type(of: self))") {
            try wait.bind(BindInputs(data: context.data))
            try wait.bind(CreateOutputStorage())
            try wait.bind(SetDependencies(container: context.dependancyContainer))
        }

        let runningWait = wait
        let nextTime = try await Failure.wrap("Failed to run waiting \(type(of: self))") {
             try await runningWait.resume()
        }
        wait = runningWait

        var readOutputs = ReadOutputs(data: context.data)

        try Failure.wrap("Failed to finish waiting \(type(of: self))") {
            try wait.bind(&readOutputs)
        }
        context.data = readOutputs.data

        if let nextTime {
            return .waiting(.time(nextTime))
        } else {
            return .completed
        }
    }
}
