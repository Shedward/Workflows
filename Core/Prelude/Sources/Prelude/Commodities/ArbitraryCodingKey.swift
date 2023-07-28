//
//  ArbitraryCodingKey.swift
//  Created by Vladislav Maltsev on 28.07.2023.
//

import Foundation

public struct ArbitraryCodingKey: CodingKey {
    public var stringValue: String = ""
    public var intValue: Int? = nil

    public init(stringValue: String) {
        self.stringValue = stringValue
    }

    public init?(intValue: Int) {
        self.intValue = intValue
    }
}
