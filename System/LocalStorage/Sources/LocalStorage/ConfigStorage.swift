//
//  ConfigStorage.swift
//
//
//  Created by v.maltsev on 28.08.2023.
//

import Foundation

public protocol ConfigStorage {
    func load<T: Decodable>(at name: String) throws -> T
}

public extension ConfigStorage {
    func load<T: Decodable>(_ type: T.Type, at name: String) throws -> T {
        try load(at: name)
    }
}
