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
        // These conditions are statically unreachable: SetDependencies
        // validates presence and type before any transition runs, and rejects
        // it with a structured `DependencyBindingFailed` error otherwise.
        // Reaching the precondition here means the binding step was skipped —
        // i.e. an engine bug.
        guard let storage else {
            preconditionFailure("Dependency<\(Value.self)> read before SetDependencies ran (engine bug)")
        }
        guard let value = storage.value else {
            preconditionFailure("Dependency<\(Value.self)> storage was reset after binding (engine bug)")
        }
        guard let value = value as? Value else {
            preconditionFailure("Dependency storage holds \(type(of: value)), expected \(Value.self) (engine bug)")
        }
        return value
    }

    public var projectedValue: Self {
        self
    }

    public init(key: StaticString? = nil) {
    }
}
