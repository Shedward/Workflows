//
//  CodableBody.swift
//  Created by Vladislav Maltsev on 18.07.2023.
//

import Foundation

public protocol JSONEncodableBody: RestBodyEncodable, Encodable, Sendable {
    static func encoder() -> JSONEncoder
}

public extension JSONEncodableBody {
    func data() throws -> Data? {
        try Self.encoder().encode(self)
    }

    static func encoder() -> JSONEncoder {
        JSONEncoder()
    }
}

public protocol JSONDecodableBody: RestBodyDecodable, Decodable, Sendable {
    static func decoder() -> JSONDecoder
}

public extension JSONDecodableBody {
    static func fromData(_ data: Data) throws -> Self {
        let decoder = Self.decoder()
        return try decoder.decode(Self.self, from: data)
    }

    static func decoder() -> JSONDecoder {
        JSONDecoder()
    }
}

public typealias JSONCodableBody = JSONEncodableBody & JSONDecodableBody
