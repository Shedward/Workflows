//
//  Input.swift
//  Workflow
//
//  Created by Vlad Maltsev on 02.01.2026.
//

@propertyWrapper
public struct Input<Value: WorkflowValue>: Sendable {
    var storage: ValueStorage?

    public var wrappedValue: Value {
        // These conditions are statically unreachable: BindInputs validates
        // presence and type before any transition runs, and rejects the
        // transition with a structured `InputBindingFailed` error if either
        // check fails. Reaching the precondition here means the binding step
        // was skipped — i.e. an engine bug.
        guard let storage else {
            preconditionFailure("Input<\(Value.self)> read before BindInputs ran (engine bug)")
        }
        guard let value = storage.value else {
            preconditionFailure("Input<\(Value.self)> storage was reset after binding (engine bug)")
        }
        guard let value = value as? Value else {
            preconditionFailure("Input storage holds \(type(of: value)), expected \(Value.self) (engine bug)")
        }
        return value
    }

    public init(key: StaticString? = nil) {
    }
}
