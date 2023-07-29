//
//  ErrorCodeTerminationValidator.swift
//  Workflows
//
//  Created by Vladislav Maltsev on 29.07.2023.
//

import Foundation

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

extension Executable {
    public func errorCodes(_ errorByCode: [Int32: Error]) -> Executable {
        terminationValidator(ErrorCodeTerminationValidator(errorByCode))
    }
}
