//
//  Failure.swift
//  Core
//
//  Created by Vlad Maltsev on 21.12.2025.
//

/// A type-erased, sendable box for any Error.
public struct AnySendableError: Error, @unchecked Sendable {
    public let base: any Error
    public init(_ base: any Error) { self.base = base }
}

public struct Failure: DescriptiveError, CustomDebugStringConvertible, Sendable {
    public let file: StaticString
    public let line: UInt
    public let message: String
    public let cause: String?

    public init(
        _ message: String,
        underlyingError: (any Error)? = nil,
        file: StaticString = #fileID,
        line: UInt = #line
    ) {
        self.file = file
        self.line = line
        self.message = message
        if let error = underlyingError {
            if let failure = error as? Failure {
                self.cause = failure.userDescription
            } else if let descriptive = error as? DescriptiveError {
                self.cause = descriptive.userDescription
            } else {
                self.cause = "\(error)"
            }
        } else {
            self.cause = nil
        }
    }

    public var debugDescription: String {
        if let cause { return "\(file):\(line): \(message)\n ↪ \(cause)" }
        return "\(file):\(line): \(message)"
    }

    public var userDescription: String {
        if let cause { return "\(message)\n ↪ \(cause)" }
        return message
    }
}

extension Failure {
    public static func wrap<Result>(
        _ message: String,
        file: StaticString = #fileID,
        line: UInt = #line,
        actions: @Sendable () throws -> Result
    ) throws -> Result {
        do {
            return try actions()
        } catch {
            throw Failure(message, underlyingError: error, file: file, line: line)
        }
    }

    public static func wrap<Result>(
        _ message: String,
        file: StaticString = #fileID,
        line: UInt = #line,
        actions: @Sendable () async throws -> Result
    ) async throws -> Result {
        do {
            return try await actions()
        } catch {
            throw Failure(message, underlyingError: error, file: file, line: line)
        }
    }
}
