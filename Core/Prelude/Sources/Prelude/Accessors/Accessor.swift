//
//  Accessor.swift
//
//
//  Created by v.maltsev on 22.08.2023.
//

public struct Accessor<Value> {
    public let `get`: () -> Value
    public let `set`: (Value) -> ()

    public var value: Value {
        get {
            get()
        }
        set {
            set(newValue)
        }
    }

    public init(
        `get`: @escaping () -> Value,
        `set`: @escaping (Value) -> Void
    ) {
        self.get = `get`
        self.set = `set`
    }
}
