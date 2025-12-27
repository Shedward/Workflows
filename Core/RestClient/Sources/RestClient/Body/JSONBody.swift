//
//  JSONBody.swift
//  RestClient
//
//  Created by Vlad Maltsev on 21.12.2025.
//

import Core
import Foundation

public protocol JSONEncodableBody: DataEncodable, Encodable, Sendable {
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

public protocol JSONDecodableBody: DataDecodable, Decodable, Sendable {
    static func decoder() -> JSONDecoder
}

public extension JSONDecodableBody {
    init(data: Data) throws {
        try self = Self.decoder().decode(Self.self, from: data)
    }

    static func decoder() -> JSONDecoder {
        JSONDecoder()
    }
}

public typealias JSONBody = JSONEncodableBody & JSONDecodableBody
