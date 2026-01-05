//
//  WorkflowData.swift
//  Workflow
//
//  Created by Vlad Maltsev on 04.01.2026.
//

public struct WorkflowData: Sendable {
    private var storage: [AnyDataKey: Sendable]

    public init(storage: [AnyDataKey : Sendable] = [:]) {
        self.storage = storage
    }

    public func get<Value>(_ key: String) -> Value? {
        storage[DataKey<Value>(name: key).eraseToAny()] as? Value
    }


    public mutating func set<Value: Sendable>(_ key: String, _ value: Value) {
        storage[DataKey<Value>(name: key).eraseToAny()] = value
    }
}
