//
//  Query.swift
//  Rest
//
//  Created by Vlad Maltsev on 21.12.2025.
//

import Core

public struct Query {
    public var values: [String: QueryConvertible]

    public init(values: [String: QueryConvertible]) {
        self.values = values
    }
}

extension Query: Sendable {}

extension Query: Defaultable {
    public init() {
        self.values = [:]
    }
}

extension Query: DictionarySemantic {}

extension Query: Modifiers {

    public func set(_ key: String, to value: Int?) -> Self {
        with { $0.values[key] = value.map(String.init) }
    }

    public func set(_ key: String, to value: [String]) -> Self {
        with {
            if value.isEmpty {
                $0.values.removeValue(forKey: key)
            } else {
                $0.values[key] = value.joined(separator: ",")
            }
        }
    }
}
