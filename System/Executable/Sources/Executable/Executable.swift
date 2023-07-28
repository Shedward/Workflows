//
//  Executable.swift
//  Workflows
//
//  Created by Vladislav Maltsev on 28.07.2023.
//

import Foundation

public struct Executable {
    public let executableURL: URL
    public var workingDirectory: URL?
    public var arguments: [String] = []
    public var environment: [String: String] = [:]


    public init(executableURL: URL) {
        self.executableURL = executableURL
    }

    public init(filePath: String) {
        self.executableURL = URL(filePath: filePath)
    }

    public func run(
        _ arguments: [String] = [],
        errorMapper: ExecutableTerminationValidator = DefaultTerminationValidator()
    ) async throws {
        let termination = try await runUnchecked(arguments)
        try errorMapper.validateTermination(termination)
    }

    public func runUnchecked(
        _ arguments: [String] = []
    ) async throws -> ExecutableTermination {
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

    func process(
        with additionalArguments: [String]
    ) -> Process {
        let process = Process()
        process.executableURL = executableURL
        process.currentDirectoryURL = workingDirectory
        process.arguments = arguments + additionalArguments
        return process
    }
}

extension Executable {
    public func workingDirectory(_ filePath: String) -> Executable {
        workingDirectory(URL(filePath: filePath))
    }

    public func setEnvironment(_ environmentKey: String, to value: String) -> Executable {
        var executable = self
        executable.environment[environmentKey] = value
        return self
    }

    public func workingDirectory(_ workingDirectory: URL) -> Executable {
        var executable = self
        executable.workingDirectory = workingDirectory
        return executable
    }

    public func arguments(_ arguments: [String]) -> Executable {
        var executable = self
        executable.arguments = arguments
        return executable
    }
}
