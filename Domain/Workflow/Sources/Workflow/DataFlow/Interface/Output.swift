//
//  Output.swift
//  Workflow
//
//  Created by Vlad Maltsev on 02.01.2026.
//

@propertyWrapper
public struct Output<Value: Sendable>: Sendable {
    var storage: ValueStorage?

    public var wrappedValue: Value {
        @available(*, unavailable)
        get {
            fatalError("Tried to read Output value")
        }
        set {
            guard let storage else {
                fatalError("Tried to use Output before setting storage")
            }

            storage.value = newValue
        }
    }

    public var projectedValue: Self {
        self
    }

    public init(key: StaticString? = nil) {
    }
}
