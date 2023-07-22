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

    public static func set(_ key: Key, to value: Value?) -> Self {
        guard let value else {
            return Self()
        }
        return Self(values: [key: value])
    }

    public static func merging(with another: Self?) -> Self {
        guard let another else {
            return Self()
        }
        return another
    }

    public func set(_ key: Key, to value: Value?) -> Self {
        var values = values
        values[key] = value
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
