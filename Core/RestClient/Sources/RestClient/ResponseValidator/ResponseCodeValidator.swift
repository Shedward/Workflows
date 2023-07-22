//
//  ResponseCodeValidator.swift
//  Created by Vladislav Maltsev on 22.07.2023.
//

import Foundation
import Prelude

public struct ResponseCodeValidator: ResponseValidator {
    public var allowedStatusCodes: [ClosedRange<Int>] = [200...299]

    public func validate(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw Failure("Failed to cast response to HTTPURLResponse")
        }

        guard allowedStatusCodes.contains(where: { $0.contains(httpResponse.statusCode) }) else {
            throw Failure("Wrong response status code \(httpResponse.statusCode)")
        }
    }
}
