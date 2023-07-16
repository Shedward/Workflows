//
//  AppError.swift
//  Created by Vladislav Maltsev on 16.07.2023.
//

struct EError: DescriptiveError {
    let context: StaticString
    let description: String
    let underlyingError: Error?

    var userDescription: String {
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

    init(_ description: String, underlyingError: Error? = nil, context: StaticString = #fileID) {
        self.context = context
        self.description = description
        self.underlyingError = underlyingError
    }
}

extension EError {
    static func wrap<Result>(
        _ description: String,
        context: StaticString = #fileID,
        actions: () throws -> Result
    ) throws -> Result {
        do {
            return try actions()
        } catch {
            throw EError(description, underlyingError: error, context: context)
        }
    }

    static func wrap<Result>(
        _ description: String,
        context: StaticString = #fileID,
        actions: () async throws -> Result
    ) async throws -> Result {
        do {
            return try await actions()
        } catch {
            throw EError(description, underlyingError: error, context: context)
        }
    }
}
