//
//  StatusCodeValidator.swift
//  RestClient
//
//  Created by Vlad Maltsev on 22.12.2025.
//

import Core
import Foundation

public struct StatusCodeValidator: URLResponseValidator {
    public var allowedStatusCodes: [ClosedRange<Int>]

    public init(allowed: [ClosedRange<Int>]) {
        self.allowedStatusCodes = allowed
    }

    public func validate(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw Failure("Failed to cast \(response) to HTTPURLResponse")
        }

        guard allowedStatusCodes.contains(where: { $0.contains(httpResponse.statusCode) })  else {
            throw Failure("Wrong status code: \(httpResponse.statusCode)")
        }
    }
}

extension StatusCodeValidator: Modifiers {

    public func disallowAll() -> Self {
        with { $0.allowedStatusCodes = [] }
    }

    public func allow(_ codes: Int...) -> Self {
        with { $0.allowedStatusCodes.append(contentsOf: codes.map { $0...$0 }) }
    }

    public func allow(_ range: ClosedRange<Int>) -> Self {
        with { $0.allowedStatusCodes.append(range) }
    }
}

extension URLResponseValidatorsSet {
    public func validateStatusCode(allowed: [ClosedRange<Int>] = [200...299]) -> Self {
        appending(StatusCodeValidator(allowed: allowed))
    }
}
