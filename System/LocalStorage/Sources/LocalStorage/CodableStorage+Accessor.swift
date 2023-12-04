//
//  CodableStorage+Accessor.swift
//  
//
//  Created by Vlad Maltsev on 04.12.2023.
//

import Prelude

extension CodableStorage {
    public func accessor<T: Codable>(for key: String) -> ThrowingAccessor<T> {
        ThrowingAccessor {
            try self.load(at: key)
        } set: { value in
            try self.save(value, at: key)
        }
    }
}
