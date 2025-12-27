//
//  Headers.swift
//  RestClient
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
    public func set(_ key: String, to: String) -> Self {
        with { $0.values[key] = to }
    }

    public func merged(_ other: Headers) -> Self {
        with { $0.values.merge(other.values, uniquingKeysWith: { $1 }) }
    }
}
