//
//  Input.swift
//  Workflow
//
//  Created by Vlad Maltsev on 02.01.2026.
//

@propertyWrapper
public struct Input<Value: Sendable>: Sendable {
    var storage: ValueStorage?

    public var wrappedValue: Value {
        guard let storage else {
            fatalError("Tried to use Input before setting storage")
        }

        guard let value = storage.value else {
            fatalError("Input \(self) is not set before usage")
        }

        guard let value = value as? Value else {
            fatalError("Storage value \(value) is not \(Value.self)")
        }

        return value
    }

    public init(key: StaticString? = nil) {
    }
}
