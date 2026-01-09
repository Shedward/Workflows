//
//  Dependency.swift
//  Workflow
//
//  Created by Vlad Maltsev on 03.01.2026.
//

@propertyWrapper
public struct Dependency<Value: Sendable>: Sendable {
    var storage: ValueStorage?

    public var wrappedValue: Value {
        guard let storage else {
            fatalError("Tried to use Dependency before setting storage")
        }

        guard let value = storage.value else {
            fatalError("Dependency \(self) is not set injected before usage")
        }

        guard let value = value as? Value else {
            fatalError("Storage value \(value) is not \(Value.self)")
        }

        return value
    }

    public var projectedValue: Self {
        self
    }

    public init(key: StaticString? = nil) {
    }
}
