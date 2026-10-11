//
//  Input.swift
//  Workflow
//
//  Created by Vlad Maltsev on 02.01.2026.
//

@propertyWrapper
public struct Input<Value: WorkflowValue>: Sendable {
    var value: Value?

    public var wrappedValue: Value {
        // Statically unreachable: BindInputs validates presence and type before any
        // transition runs, and rejects it with a structured `InputBindingFailed` error
        // otherwise. Reaching this means the binding step was skipped, i.e. an engine bug.
        guard let value else {
            preconditionFailure("Input<\(Value.self)> read before BindInputs ran (engine bug)")
        }
        return value
    }

    public init(key: StaticString? = nil) {
    }
}
