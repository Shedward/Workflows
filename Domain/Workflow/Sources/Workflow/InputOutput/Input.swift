//
//  Input.swift
//  Workflow
//
//  Created by Vlad Maltsev on 02.01.2026.
//

@propertyWrapper
public struct Input<Value> {
    public let key: DataKey
    private var value: Value?

    public var wrappedValue: Value {
        guard let value else {
            fatalError("Input \(self) is not set before usage")
        }
        return value
    }

    public init(key: DataKey) {
        self.key = key
    }

    mutating func supply(_ value: Value) {
        self.value = value
    }
}
