//
//  KeyValueBuildable.swift
//  Created by Vladislav Maltsev on 17.07.2023.
//

protocol DictionaryBuildable {
    associatedtype Key: Hashable
    associatedtype Value

    var values: [Key: Value] { get set }

    init(values: [Key: Value])
}

extension DictionaryBuildable {

    var isEmpty: Bool {
        values.isEmpty
    }

    init() {
        self.init(values: [:])
    }

    static func set(_ key: Key, to value: Value) -> Self {
        Self(values: [key: value])
    }

    func set(_ key: Key, to value: Value) -> Self {
        var values = values
        values[key] = value
        return Self(values: values)
    }

    func merging(with another: Self) -> Self {
        return Self(
            values: values.merging(another.values, uniquingKeysWith: { $1 })
        )
    }
}
