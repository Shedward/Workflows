//
//  ArbitraryCodingKey.swift
//  Created by Vladislav Maltsev on 28.07.2023.
//

import Foundation

public typealias ArbitraryCodingKeyPath = [ArbitraryCodingKey]

public struct ArbitraryCodingKey: CodingKey, Hashable {
    public var stringValue: String = ""
    public var intValue: Int? = nil

    public var isIndexKey: Bool {
        intValue != nil
    }

    public init(stringValue: String) {
        self.stringValue = stringValue
    }

    public init?(intValue: Int) {
        self.intValue = intValue
    }

    public init(codingKey: CodingKey) {
        self.stringValue = codingKey.stringValue
        self.intValue = codingKey.intValue
    }
}

extension ArbitraryCodingKey: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self.init(stringValue: value)
    }
}

extension ArbitraryCodingKey: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: IntegerLiteralType) {
        self.init(intValue: value)!
    }
}
