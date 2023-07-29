//
//  ExecutableTerminationValidator.swift
//  Workflows
//
//  Created by Vladislav Maltsev on 28.07.2023.
//

public protocol ExecutableTerminationValidator: Sendable {
    func validateTermination(_ termination: ExecutableTermination) throws
}

public struct DefaultTerminationValidator: ExecutableTerminationValidator {
    public init() {
    }

    public func validateTermination(_ termination: ExecutableTermination) throws {
        if termination.isSuccessful {
            return
        } else {
            throw ExecutableError.unsuccessfullTermination(termination)
        }
    }
}
