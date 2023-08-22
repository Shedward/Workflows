//
//  AsyncThrowingAccessor.swift
//  
//
//  Created by v.maltsev on 22.08.2023.
//

public struct AsyncThrowingAccessor<Value> {
    public let get: () async throws -> Value
    public let set: (Value) async throws -> ()

    public init(
        `get`: @escaping () async throws -> Value,
        `set`: @escaping (Value) async throws -> Void
    ) {
        self.get = `get`
        self.set = `set`
    }
}
