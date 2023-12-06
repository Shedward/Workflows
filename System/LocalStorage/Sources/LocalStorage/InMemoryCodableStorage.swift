//
//  InMemoryCodableStorage.swift
//  
//
//  Created by Vlad Maltsev on 23.10.2023.
//

import Prelude

public final class InMemoryCodableStorage: CodableStorage {
    
    private var stored: [String: Any]
    
    public init(stored: [String : Any] = [:]) {
        self.stored = stored
    }
    
    public func load<T>(at key: String) throws -> T where T : Decodable {
        guard let any = stored[key] else {
            throw Failure("Not found value for key \(key)")
        }
        guard let value = any as? T else {
            throw Failure("Expected \(T.self) but found \(type(of: any))")
        }
        return value
    }
    
    public func save<T>(_ value: T, at key: String) throws where T : Encodable {
        stored[key] = value
    }
    
    public func exists(at key: String) -> Bool {
        stored[key] != nil
    }
}
