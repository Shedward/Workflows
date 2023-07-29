//
//  Executable+Run.swift
//  Workflows
//
//  Created by Vladislav Maltsev on 29.07.2023.
//

import Foundation

extension Executable {

    public func run(_ arguments: String...) async throws {
        try await run(arguments)
    }

    public func run(_ arguments: [String]) async throws {
        let termination = try await runUnchecked(arguments)
        try terminationValidator.validateTermination(termination)
    }

    public func runUnchecked(_ arguments: String...) async throws -> ExecutableTermination {
        try await runUnchecked(arguments)
    }

    public func runUnchecked(_ arguments: [String]) async throws -> ExecutableTermination {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<ExecutableTermination, Error>) in
            let process = process(with: arguments)
            process.terminationHandler = { process in
                let termination = ExecutableTermination(
                    reason: .init(processTerminationReason: process.terminationReason),
                    status: process.terminationStatus
                )
                continuation.resume(returning: termination)
            }
            do {
                try process.run()
            } catch {
                continuation.resume(throwing: ExecutableError.failedToRun(error))
            }
        }
    }

    public func runForDataOutput(_ arguments: String...) async throws -> Data {
        try await runForDataOutput(arguments)
    }

    public func runForDataOutput(_ arguments: [String]) async throws -> Data {
        let output = Pipe()

        try await self
            .output(to: output)
            .run(arguments)

        let data = output.fileHandleForReading.availableData
        return data
    }

    public func runForOutput(_ arguments: String...) async throws -> String {
        try await runForOutput(arguments)
    }

    public func runForOutput(_ arguments: [String]) async throws -> String {
        let data = try await runForDataOutput(arguments)
        return String(data: data, encoding: .utf8) ?? ""
    }
}
