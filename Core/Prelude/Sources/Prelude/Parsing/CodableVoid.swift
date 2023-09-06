//
//  DecodableVoid.swift
//
//
//  Created by v.maltsev on 06.09.2023.
//

public struct CodableVoid: Codable, Sendable {
    public init() {
    }

    public init(from decoder: Decoder) throws {
        self.init()
    }

    public func encode(to encoder: Encoder) throws {
    }
}

extension KeyedDecodingContainer {
    public func decodeVoidable<T>(
        _ type: T.Type,
        forKey key: Key
    ) throws -> T where T : Decodable {
        try decode(T.self, forKey: key)
    }

    public func decodeVoidable(
        _ type: CodableVoid.Type,
        forKey key: Key
    ) throws -> CodableVoid {
        .init()
    }
}
