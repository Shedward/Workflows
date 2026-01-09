//
//  PathElement.swift
//  API
//
//  Created by Vlad Maltsev on 08.01.2026.
//

import Core

public struct PathElements {
    public var values: [String: String]

    public init(values: [String: String]) {
        self.values = values
    }

    public func apply(to path: String) -> String {
        values.reduce(path) { result, element in
            result.replacingOccurrences(of: ":\(element.key)", with: element.value)
        }
    }
}

extension PathElements: Sendable {}
extension PathElements: Equatable {}
extension PathElements: DictionarySemantic {}

extension PathElements: Defaultable {
    public init() {
        self.values = [:]
    }
}

extension PathElements: Modifiers {}
