//
//  AppError.swift
//  Created by Vladislav Maltsev on 16.07.2023.
//

public struct Failure: DescriptiveError {
    public let context: StaticString
    public let description: String
    public let underlyingError: Error?

    public var userDescription: String {
        if let underlyingError {
            let errorDescription: String = (underlyingError as? DescriptiveError)?.userDescription
            ?? "\(underlyingError)"

            return """
            \(context): \(description)
             ↪ \(errorDescription)
            """
        } else {
            return "\(context): \(description)"
        }
    }

    public init(_ description: String, underlyingError: Error? = nil, context: StaticString = #fileID) {
        self.context = context
        self.description = description
        self.underlyingError = underlyingError
    }
}

extension Failure {
    public static func wrap<Result>(
        _ description: String,
        context: StaticString = #fileID,
        actions: () throws -> Result
    ) throws -> Result {
        do {
            return try actions()
        } catch {
            throw Failure(description, underlyingError: error, context: context)
        }
    }

    public static func wrap<Result>(
        _ description: String,
        context: StaticString = #fileID,
        actions: () async throws -> Result
    ) async throws -> Result {
        do {
            return try await actions()
        } catch {
            throw Failure(description, underlyingError: error, context: context)
        }
    }
}
