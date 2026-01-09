//
//  URLResponseValidatorsSet.swift
//  Rest
//
//  Created by Vlad Maltsev on 21.12.2025.
//

import Core
import Foundation

public struct URLResponseValidatorsSet: URLResponseValidator {
    public var items: [URLResponseValidator]

    public init() {
        self.items = []
    }

    public func validate(_ response: URLResponse) throws {
        for item in items {
            try item.validate(response)
        }
    }
}

extension URLResponseValidatorsSet: Defaultable { }
extension URLResponseValidatorsSet: ArraySemantic { }
extension URLResponseValidatorsSet: Modifiers { }
