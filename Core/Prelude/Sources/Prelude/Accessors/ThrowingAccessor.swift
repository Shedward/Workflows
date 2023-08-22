//
//  ThrowingAccessor.swift
//
//
//  Created by v.maltsev on 22.08.2023.
//

import Foundation

public struct ThrowingAccessor<Value> {
    public let get: () throws -> Value
    public let set: (Value) throws -> ()

    public init(
        `get`: @escaping () throws -> Value,
        `set`: @escaping (Value) throws -> Void
    ) {
        self.get = `get`
        self.set = `set`
    }
}
