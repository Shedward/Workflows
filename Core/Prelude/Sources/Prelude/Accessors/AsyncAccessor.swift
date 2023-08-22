//
//  AsyncAccessor.swift
//
//
//  Created by v.maltsev on 22.08.2023.
//

public struct AsyncAccessor<Value> {
    public let get: () async -> Value
    public let set: (Value) async -> ()

    public init(`get`: @escaping () -> Value, `set`: @escaping (Value) -> Void) {
        self.get = `get`
        self.set = `set`
    }
}
