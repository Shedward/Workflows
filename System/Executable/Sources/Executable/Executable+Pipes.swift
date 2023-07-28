//
//  Executable+Pipes.swift
//  Workflows
//
//  Created by Vladislav Maltsev on 29.07.2023.
//

import Foundation
import Prelude

extension Executable {
    public func input(to pipe: ExecutablePipe) -> Executable {
        var executable = self
        executable.pipes.input = pipe
        return executable
    }

    public func output(to pipe: ExecutablePipe) -> Executable {
        var executable = self
        executable.pipes.output = pipe
        return executable
    }

    public func errorOutput(to pipe: ExecutablePipe) -> Executable {
        var executable = self
        executable.pipes.error = pipe
        return executable
    }

    mutating public func bindInput(to string: String) throws {
        guard let data = string.data(using: .utf8) else {
            throw Failure("Failed to convert string to data")
        }
        try bindInput(to: data)
    }

    mutating public func bindInput(to data: Data) throws {
        let pipe = Pipe()
        pipes.input = pipe
        try pipe.fileHandleForWriting.write(contentsOf: data)
    }

    mutating public func bindOutput(to another: inout Executable) {
        let pipe = Pipe()
        pipes.output = pipe
        another.pipes.input = pipe
    }
}
