//
//  Metadata.swift
//  Core
//
//  Created by Vlad Maltsev on 23.12.2025.
//

public struct Metadata: Sendable {
    private var storage: [ObjectIdentifier: any Sendable] = [:]

    public init() {
    }

    public subscript<K: MetadataKey>(key: K.Type) -> K.Value {
        get {
            if let value = storage[ObjectIdentifier(key)] as? K.Value {
                return value
            }
            return K.defaultValue
        }
        set {
            storage[ObjectIdentifier(key)] = newValue
        }
    }
}

extension Metadata: Defaultable {}
