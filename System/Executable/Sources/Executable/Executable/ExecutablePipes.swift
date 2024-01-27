//
//  ExecutablePipes.swift
//  Workflows
//
//  Created by Vladislav Maltsev on 29.07.2023.
//

import Foundation

public protocol ExecutablePipe: Sendable {
    var lines: AsyncLineSequence<FileHandle.AsyncBytes> { get }
}

extension Pipe: ExecutablePipe {
    public var lines: AsyncLineSequence<FileHandle.AsyncBytes> {
        fileHandleForReading.bytes.lines
    }
}
extension FileHandle: ExecutablePipe {
    public var lines: AsyncLineSequence<AsyncBytes> {
        bytes.lines
    }
}

public struct ExecutablePipes: Sendable {
    public var input: ExecutablePipe?
    public var output: ExecutablePipe?
    public var error: ExecutablePipe?

    public init(
        input: ExecutablePipe? = FileHandle.standardInput,
        output: ExecutablePipe? = FileHandle.standardOutput,
        error: ExecutablePipe? = FileHandle.standardError
    ) {
        self.input = input
        self.output = output
        self.error = error
    }
}
