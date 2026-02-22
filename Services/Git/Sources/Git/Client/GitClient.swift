//
//  GitClient.swift
//  Git
//
//  Created by Vlad Maltsev on 22.02.2026.
//

import Core
import System
import Subprocess

public struct GitClient: Sendable {
    let workingPath: FilePath?

    func run<Output: OutputProtocol, Error: ErrorOutputProtocol>(
        _ command: String,
        arguments: String...,
        output: Output = .string(limit: 4096),
        error: Error = .discarded
    ) async throws -> CollectedResult<Output, Error> {
        try await Failure.wrap("Failed git \(command) \(arguments)") {
            try await Subprocess.run(
                .name("git"),
                arguments: .init([command] + arguments),
                workingDirectory: workingPath,
                output: output,
                error: error
            )
        }
    }
}
