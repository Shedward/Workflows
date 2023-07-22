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

    public static func set(_ key: Key, to value: Value) -> Self {
        Self(values: [key: value])
    }

    public func set(_ key: Key, to value: Value) -> Self {
        var values = values
        values[key] = value
        return Self(values: values)
    }

    public func merging(with another: Self) -> Self {
        return Self(
            values: values.merging(another.values, uniquingKeysWith: { $1 })
        )
    }

    public mutating func merge(_ another: Self) {
        values = values.merging(another.values, uniquingKeysWith: { $1 })
    }
}
