//
//  Ask.swift
//  WorkflowEngine
//
//  Created by Vlad Maltsev on 04.04.2026.
//

@propertyWrapper
public struct Ask<Value: WorkflowValue>: Sendable {
    var storage: ValueStorage?

    public var wrappedValue: Value {
        get {
            guard let storage else {
                fatalError("Tried to use Ask before setting storage")
            }

            guard let value = storage.value else {
                fatalError("Ask \(self) is not set before usage")
            }

            guard let value = value as? Value else {
                fatalError("Storage value \(value) is not \(Value.self)")
            }

            return value
        }
        nonmutating set {
            guard let storage else {
                fatalError("Tried to use Ask before setting storage")
            }

            storage.value = newValue
        }
    }

    public init(key: StaticString? = nil) {
    }
}
