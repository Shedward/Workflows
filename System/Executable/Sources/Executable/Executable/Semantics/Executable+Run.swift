//
//  Executable+Run.swift
//
//
//  Created by Vlad Maltsev on 30.09.2023.
//

import Foundation
import Prelude

extension Executable {
    public func run() async throws -> ExecutableTermination {
        try await execute()
    }
    
    public func run(_ arguments: String...) async throws -> ExecutableTermination {
        try await appendingArguments(arguments).run()
    }
    
    public func runForDataOutput(
        _ arguments: String...,
        finished: TerminationRule = .successfull
    ) async throws -> Data {
        let pipe = Pipe()
        try await output(to: pipe)
            .appendingArguments(arguments)
            .run()
            .finished(finished)
        let data = pipe.fileHandleForReading.availableData
        return data
    }
    
    public func runForOutput(
        _ arguments: String...,
        encoding: String.Encoding = .utf8,
        finished: TerminationRule = .successfull
    ) async throws -> String {
        let pipe = Pipe()
        try await output(to: pipe)
            .appendingArguments(arguments)
            .run()
            .finished(finished)
        let data = pipe.fileHandleForReading.availableData
        guard let string = String(data: data, encoding: encoding) else {
            throw Failure("Failed to decode output data")
        }
        return string
    }
}
