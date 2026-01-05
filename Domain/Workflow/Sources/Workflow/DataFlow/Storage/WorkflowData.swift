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

    public func get<Value>(_ key: DataKey<Value>) -> Value? {
        storage[key.eraseToAny()] as? Value
    }


    public mutating func set<Value: Sendable>(_ key: DataKey<Value>, _ value: Value) {
        storage[key.eraseToAny()] = value
    }
}
