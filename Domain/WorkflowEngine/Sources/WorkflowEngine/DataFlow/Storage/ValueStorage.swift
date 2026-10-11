//
//  ValueStorage.swift
//  Workflow
//
//  Created by Vlad Maltsev on 03.01.2026.
//

import os

final class ValueStorage: Sendable {
    private let storedValue: OSAllocatedUnfairLock<Sendable?>

    var value: Sendable? {
        get {
            storedValue.withLock { $0 }
        }
        set {
            storedValue.withLock { $0 = newValue }
        }
    }

    init(_ value: Sendable? = nil) {
        storedValue = OSAllocatedUnfairLock(initialState: value)
    }
}
