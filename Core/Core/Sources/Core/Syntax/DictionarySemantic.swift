//
//  KeyValueModifiers.swift
//  Core
//
//  Created by Vlad Maltsev on 21.12.2025.
//

public protocol DictionarySemantic {
    associatedtype Key: Hashable
    associatedtype Value

    var values: [Key: Value] { get set }
}

extension DictionarySemantic {
    public subscript (_ key: Key) -> Value? {
        get { values[key] }
        set { values[key] = newValue }
    }
}

extension Modifiers where Self: DictionarySemantic {

    public var isEmpty: Bool {
        values.isEmpty
    }

    public func set(_ key: Key, to value: Value) -> Self {
        with { $0.values[key] = value }
    }

    public mutating func merge(_ other: Self) {
        values.merge(other.values, uniquingKeysWith: { $1 })
    }

    public func merging(_ other: Self) -> Self {
        with { $0.merge(other) }
    }
}

extension Modifiers where Self: Defaultable, Self: DictionarySemantic {

    public static func set(_ key: Key, to value: Value) -> Self {
        Self().set(key, to: value)
    }

    public init(_ key: Key, to value: Value) {
        self = .init().set(key, to: value)
    }
}
