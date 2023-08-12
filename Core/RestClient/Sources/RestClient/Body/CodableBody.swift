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
}

public protocol JSONDecodableBody: RestBodyDecodable, Decodable, Sendable {
    static func decoder() -> JSONDecoder
}

public extension JSONDecodableBody {
    static func fromData(_ data: Data) throws -> Self {
        try Self.decoder().decode(Self.self, from: data)
    }

    static func decoder() -> JSONDecoder {
        JSONDecoder()
    }
}

public typealias JSONCodableBody = JSONEncodableBody & JSONDecodableBody
