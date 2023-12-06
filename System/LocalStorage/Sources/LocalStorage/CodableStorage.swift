//
//  CodableStorage.swift
//
//
//  Created by v.maltsev on 28.08.2023.
//

import Foundation

public protocol CodableStorage {
    func load<T: Decodable>(at key: String) throws -> T
    func save<T: Encodable>(_ value: T, at key: String) throws
    func exists(at key: String) -> Bool
}

public extension CodableStorage {
    func load<T: Decodable>(_ type: T.Type, at name: String) throws -> T {
        try load(at: name)
    }
}
