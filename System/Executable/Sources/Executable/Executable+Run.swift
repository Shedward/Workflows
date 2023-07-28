//
//  Executable+Run.swift
//  Workflows
//
//  Created by Vladislav Maltsev on 29.07.2023.
//

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
}
