//
//  JQLQuery.swift
//  Created by Vladislav Maltsev on 26.07.2023.
//

public struct JQLQuery {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

extension JQLQuery: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self.init(rawValue: value)
    }
}
