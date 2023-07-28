//
//  ExecutableTerminationValidator.swift
//  Workflows
//
//  Created by Vladislav Maltsev on 28.07.2023.
//

public protocol ExecutableTerminationValidator {
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

public struct ErrorCodeTerminationValidator: ExecutableTerminationValidator {
    private var errorByCode: [Int32: Error]

    public init(_ errorByCode: [Int32: Error]) {
        self.errorByCode = errorByCode
    }

    public func validateTermination(_ termination: ExecutableTermination) throws {
        guard !termination.isSuccessful else {
            return
        }

        guard termination.reason == .exit else {
            throw ExecutableError.unsuccessfullTermination(termination)
        }

        if let specifiedError = errorByCode[termination.status] {
            throw specifiedError
        }

        throw ExecutableError.unsuccessfullTermination(termination)
    }
}
