//
//  ProcessExecutable.swift
//  Workflows
//
//  Created by Vladislav Maltsev on 28.07.2023.
//

import Foundation
import Prelude
import os

public struct ProcessExecutable: Sendable, Executable {
    private let executableURL: URL
    
    public var workingDirectory: URL?
    public var arguments: [String]
    public var pipes: ExecutablePipes = .init()
    public var environment: [String : String] = [:]

    public init(executableURL: URL) {
        self.executableURL = executableURL
        self.arguments = []
    }

    public init(path: String, _ arguments: String...) {
        self.executableURL = URL(filePath: path)
        self.arguments = arguments
    }

    public init(command: String, _ arguments: String...) {
        self.executableURL = URL(filePath: "/usr/bin/env")
        self.arguments = [command] + arguments
    }
    
    public func execute() async throws -> ExecutableTermination {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<ExecutableTermination, Error>) in
            let logger = Logger(scope: .executables)
            logger.trace("""
            → Execute \(executableURL.path(percentEncoded: false)) \(arguments)
              At \(workingDirectory?.path(percentEncoded: false) ?? "current directory")
              Environment \(environment)
            """)
            
            let process = createProcess()
            process.terminationHandler = { process in
                let termination = ExecutableTermination(
                    reason: .init(processTerminationReason: process.terminationReason),
                    status: process.terminationStatus
                )
                logger.trace("""
                ← Finished \(executableURL.path(percentEncoded: false)) \(arguments)
                """)
                continuation.resume(returning: termination)
            }
            do {
                try process.run()
            } catch {
                logger.error("""
                ← Failed \(executableURL.path(percentEncoded: false)) \(arguments)
                \(error)
                """)
                continuation.resume(throwing: ExecutableError.failedToRun(error))
            }
        }
    }
    
    private func createProcess() -> Process {
        let process = Process()
        process.executableURL = executableURL
        process.currentDirectoryURL = workingDirectory
        process.arguments = self.arguments + arguments
        process.standardInput = pipes.input
        process.standardOutput = pipes.output
        process.standardError = pipes.error
        return process
    }
}
