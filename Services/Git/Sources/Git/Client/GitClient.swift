//
//  GitClient.swift
//  Git
//
//  Created by Vlad Maltsev on 22.02.2026.
//

import Core
import Subprocess
import System

public struct GitClient: Sendable {
    let workingPath: FilePath?

    func run<Output: OutputProtocol, Error: ErrorOutputProtocol>(
        _ command: String,
        arguments: String...,
        output: Output = .string(limit: 4096),
        error: Error = .discarded
    ) async throws -> ExecutionResult<Void, Output, Error> {
        // `ExecutionResult` is noncopyable, so it can't pass through the generic `Failure.wrap`.
        do {
            return try await Subprocess.run(
                .name("git"),
                arguments: .init([command] + arguments),
                workingDirectory: workingPath,
                output: output,
                error: error
            )
        } catch {
            throw Failure("Failed git \(command) \(arguments)", underlyingError: error)
        }
    }
}
