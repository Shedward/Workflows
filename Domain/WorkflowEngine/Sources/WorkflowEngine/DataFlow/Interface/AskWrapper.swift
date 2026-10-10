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
                preconditionFailure("Ask<\(Value.self)> read before CreateOutputStorage ran (engine bug)")
            }

            guard let value = storage.value else {
                preconditionFailure("Ask<\(Value.self)> read before it was answered; read it only after the answer arrived")
            }

            guard let value = value as? Value else {
                preconditionFailure("Ask<\(Value.self)> holds \(type(of: value)), not \(Value.self) (engine bug)")
            }

            return value
        }
        nonmutating set {
            guard let storage else {
                preconditionFailure("Ask<\(Value.self)> set before CreateOutputStorage ran (engine bug)")
            }

            storage.value = newValue
        }
    }

    public init(key: StaticString? = nil) {
    }
}
