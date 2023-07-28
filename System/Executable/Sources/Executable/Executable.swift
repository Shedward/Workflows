//
//  Executable.swift
//  Workflows
//
//  Created by Vladislav Maltsev on 28.07.2023.
//

import Foundation
import Prelude

public struct Executable: Sendable {
    public let executableURL: URL
    public var workingDirectory: URL?
    public var arguments: [String] = []
    public var environment: [String: String] = [:]
    public var terminationValidator: ExecutableTerminationValidator = DefaultTerminationValidator()

    public var pipes: ExecutablePipes = .init()

    public init(executableURL: URL) {
        self.executableURL = executableURL
    }

    public init(path: String, _ arguments: String...) {
        self.executableURL = URL(filePath: path)
        self.arguments = arguments
    }

    public init(command: String, _ arguments: String...) {
        self.executableURL = URL(filePath: "/usr/bin/env")
        self.arguments = [command] + arguments
    }

    func process(
        with additionalArguments: [String]
    ) -> Process {
        let process = Process()
        process.executableURL = executableURL
        process.currentDirectoryURL = workingDirectory
        process.arguments = arguments + additionalArguments
        process.standardInput = pipes.input
        process.standardOutput = pipes.output
        process.standardError = pipes.error
        return process
    }
}

extension Executable {
    public func setEnvironment(_ environmentKey: String, to value: String) -> Executable {
        var executable = self
        executable.environment[environmentKey] = value
        return self
    }

    public func workingDirectory(_ filePath: String) -> Executable {
        workingDirectory(URL(filePath: filePath))
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

    public func appendingArguments(_ arguments: [String]) -> Executable {
        var executable = self
        executable.arguments += arguments
        return executable
    }

    public func terminationValidator(_ validator: ExecutableTerminationValidator) -> Executable {
        var executable = self
        executable.terminationValidator = validator
        return executable
    }
}
