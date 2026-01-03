//
//  Output.swift
//  Workflow
//
//  Created by Vlad Maltsev on 02.01.2026.
//

@propertyWrapper
public struct Output<Value> {
    public let key: DataKey
    private var value: Value?

    public var wrappedValue: Value {
        @available(*, unavailable)
        get {
            fatalError("Tried to read Output value")
        }
        set {
            value = newValue
        }
    }

    public init(key: DataKey, wrappedValue: Value) {
        self.key = key
        self.wrappedValue = wrappedValue
    }

    func collect() -> Value? {
        value
    }
}
