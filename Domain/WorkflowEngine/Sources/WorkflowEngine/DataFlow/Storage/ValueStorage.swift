//
//  ValueStorage.swift
//  Workflow
//
//  Created by Vlad Maltsev on 03.01.2026.
//

import os.lock

final class ValueStorage: @unchecked Sendable {
    private var _value: Sendable?
    private var lock = os_unfair_lock_s()

    var value: Sendable? {
        get {
            os_unfair_lock_lock(&lock)
            let value = _value
            os_unfair_lock_unlock(&lock)
            return value
        }
        set {
            os_unfair_lock_lock(&lock)
            _value = newValue
            os_unfair_lock_unlock(&lock)
        }
    }

    init(_ value: Sendable? = nil) {
        _value = value
    }
}

extension Optional where Wrapped == ValueStorage {
    /// Reads the value a binding attached to a property wrapper before the transition ran.
    ///
    /// The failures here are statically unreachable: `binding` validates presence and type first
    /// and rejects the transition with a structured error otherwise. Reaching a precondition
    /// means the binding step was skipped, i.e. an engine bug.
    func boundValue<Value>(of wrapper: String, boundBy binding: String) -> Value {
        guard let self else {
            preconditionFailure("\(wrapper)<\(Value.self)> read before \(binding) ran (engine bug)")
        }
        guard let value = self.value else {
            preconditionFailure("\(wrapper)<\(Value.self)> storage was reset after binding (engine bug)")
        }
        guard let value = value as? Value else {
            preconditionFailure("\(wrapper) storage holds \(type(of: value)), expected \(Value.self) (engine bug)")
        }
        return value
    }
}
