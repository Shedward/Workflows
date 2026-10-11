//
//  Dependency.swift
//  Workflow
//
//  Created by Vlad Maltsev on 03.01.2026.
//

@propertyWrapper
public struct Dependency<Value: Sendable>: Sendable {
    var value: Value?

    public var wrappedValue: Value {
        // Statically unreachable: SetDependencies validates presence and type before any
        // transition runs, and rejects it with a structured `DependencyBindingFailed` error
        // otherwise. Reaching this means the binding step was skipped, i.e. an engine bug.
        guard let value else {
            preconditionFailure("Dependency<\(Value.self)> read before SetDependencies ran (engine bug)")
        }
        return value
    }

    public init(key: StaticString? = nil) {
    }
}
