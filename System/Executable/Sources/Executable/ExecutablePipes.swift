//
//  ExecutablePipes.swift
//  Workflows
//
//  Created by Vladislav Maltsev on 29.07.2023.
//

import Foundation

public protocol ExecutablePipe: Sendable { }

extension Pipe: ExecutablePipe { }
extension FileHandle: ExecutablePipe { }

public struct ExecutablePipes: Sendable {
    public var input: ExecutablePipe?
    public var output: ExecutablePipe?
    public var error: ExecutablePipe?

    init(
        input: ExecutablePipe? = FileHandle.standardInput,
        output: ExecutablePipe? = FileHandle.standardOutput,
        error: ExecutablePipe? = FileHandle.standardError
    ) {
        self.input = input
        self.output = output
        self.error = error
    }
}
