//
//  Headers.swift
//  Rest
//
//  Created by Vlad Maltsev on 21.12.2025.
//

import Core

public struct Headers {
    public var values: [String: String]

    public init(values: [String: String]) {
        self.values = values
    }
}

extension Headers: Sendable {}
extension Headers: Equatable {}
extension Headers: DictionarySemantic {}

extension Headers: Defaultable {
    public init() {
        self.values = [:]
    }
}

extension Headers: Modifiers {
}
