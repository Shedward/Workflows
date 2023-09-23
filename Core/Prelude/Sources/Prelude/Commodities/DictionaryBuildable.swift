//
//  KeyValueBuildable.swift
//  Created by Vladislav Maltsev on 17.07.2023.
//

public protocol DictionaryBuildable {
    associatedtype Key: Hashable
    associatedtype Value

    var values: [Key: Value] { get set }

    init(values: [Key: Value])
}

extension DictionaryBuildable {

    public var isEmpty: Bool {
        values.isEmpty
    }

    public init() {
        self.init(values: [:])
    }

    public func set(_ key: Key, to value: Value?) -> Self {
        var values = values
        values[key] = value
        return Self(values: values)
    }

    public func withoutKeys(_ keys: Set<Key>) -> Self {
        let values = values.filter { !keys.contains($0.key) }
        return Self(values: values)
    }

    public func withKeys(_ keys: Set<Key>) -> Self {
        let values = values.filter { keys.contains($0.key) }
        return Self(values: values)
    }

    public func merging(with another: Self?) -> Self {
        guard let another else { return self }
        return Self(
            values: values.merging(another.values, uniquingKeysWith: { $1 })
        )
    }

    public mutating func merge(_ another: Self?) {
        guard let another else { return }
        values = values.merging(another.values, uniquingKeysWith: { $1 })
    }
}

extension DictionaryBuildable where Value: Equatable {

    public func contains(_ another: Self) -> Bool {
        for (key, value) in another.values {
            guard let anotherValue = another.values[key] else {
                return false
            }

            guard value == anotherValue else {
                return false
            }
        }

        return true
    }
}
