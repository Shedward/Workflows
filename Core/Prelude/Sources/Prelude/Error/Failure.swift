//
//  AppError.swift
//  Created by Vladislav Maltsev on 16.07.2023.
//

public struct Failure: DescriptiveError, CustomDebugStringConvertible {
    public let file: StaticString
    public let line: UInt
    public let description: String
    public let underlyingError: Error?

    public init(_ description: String, underlyingError: Error? = nil, file: StaticString = #fileID, line: UInt = #line) {
        self.file = file
        self.line = line
        self.description = description
        self.underlyingError = underlyingError
    }

    public var debugDescription: String {
        descriptionString(includeContext: true)
    }

    public var userDescription: String {
        descriptionString(includeContext: false)
    }

    private func descriptionString(includeContext: Bool) -> String {
        if let underlyingError {
            let errorDescription: String =
                (underlyingError as? Failure)?.descriptionString(includeContext: includeContext)
                ?? (underlyingError as? DescriptiveError)?.userDescription
                ?? "\(underlyingError)"

            return """
            \(currentErrorDescriptionString(includeContext: includeContext))
             ↪ \(errorDescription)
            """
        } else {
            return currentErrorDescriptionString(includeContext: includeContext)
        }
    }

    private func currentErrorDescriptionString(includeContext: Bool) -> String {
        if includeContext {
            return "\(file):\(line): \(description)"
        } else {
            return description
        }
    }
}

extension Failure {
    public static func wrap<Result>(
        _ description: String,
        file: StaticString = #fileID,
        line: UInt = #line,
        actions: () throws -> Result
    ) throws -> Result {
        do {
            return try actions()
        } catch {
            throw Failure(description, underlyingError: error, file: file, line: line)
        }
    }

    public static func wrap<Result>(
        _ description: String,
        file: StaticString = #fileID,
        line: UInt = #line,
        actions: () async throws -> Result
    ) async throws -> Result {
        do {
            return try await actions()
        } catch {
            throw Failure(description, underlyingError: error, file: file, line: line)
        }
    }
}
