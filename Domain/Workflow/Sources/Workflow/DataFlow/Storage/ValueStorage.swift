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

    init(_ value: Sendable? = nil) {
        _value = value
    }

    var value: Sendable? {
        get {
            os_unfair_lock_lock(&lock)
            let v = _value
            os_unfair_lock_unlock(&lock)
            return v
        }
        set {
            os_unfair_lock_lock(&lock)
            _value = newValue
            os_unfair_lock_unlock(&lock)
        }
    }
}
