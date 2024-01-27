//
//  TerminationRule.swift
//
//
//  Created by Vlad Maltsev on 30.09.2023.
//

public struct TerminationRule {
    public typealias Check = (ExecutableTermination) throws -> Void
    
    let checkTermination: Check
    
    init(checkTermination: @escaping Check) {
        self.checkTermination = checkTermination
    }
    
    public static var successfull: TerminationRule {
        TerminationRule { termination in
            if !termination.isSuccessful {
                throw ExecutableError.unsuccessfullTermination(termination)
            }
        }
    }
    
    public static var ignore: TerminationRule {
        TerminationRule { _ in }
    }
    
    public static func expectedCode(_ expectedCode: Int32) -> TerminationRule {
        TerminationRule { termination in
            guard termination.reason == .exit else {
                throw ExecutableError.unsuccessfullTermination(termination)
            }
            
            if termination.status != expectedCode {
                throw ExecutableError.unsuccessfullTermination(termination)
            }
        }
    }
    
    public static func errorCodes(_ errorByCode: [Int32: Error]) -> TerminationRule {
        TerminationRule { termination in
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
    
    public static func custom(_ checkTermination: @escaping Check) -> TerminationRule {
        TerminationRule(checkTermination: checkTermination)
    }
}

extension ExecutableTermination {
    public func finished(_ rule: TerminationRule = .successfull) throws {
        try rule.checkTermination(self)
    }
    
    public func mapStatusCode<Output>(_ transform: (Int32) throws -> Output) throws -> Output {
        guard
            reason == .exit
        else {
            throw ExecutableError.unsuccessfullTermination(self)
        }
        
        return try transform(self.status)
    }
    
    public func mapStatusCode<Output>(_ outputByCode: [Int32: Output]) throws -> Output {
        guard 
            reason == .exit,
            let output = outputByCode[status]
        else {
            throw ExecutableError.unsuccessfullTermination(self)
        }
        
        return output
    }
}
