//
//  JSONBody.swift
//  Rest
//
//  Created by Vlad Maltsev on 21.12.2025.
//

import Core
import Foundation

public protocol JSONEncodableBody: DataEncodable, Encodable, Sendable {
    static func encoder() -> JSONEncoder
}

public extension JSONEncodableBody {
    static func encoder() -> JSONEncoder {
        JSONEncoder()
    }

    var contentType: String? { "application/json" }

    func data() throws -> Data? {
        try Self.encoder().encode(self)
    }
}

public protocol JSONDecodableBody: DataDecodable, Decodable, Sendable {
    static func decoder() -> JSONDecoder
}

public extension JSONDecodableBody {
    static func decoder() -> JSONDecoder {
        JSONDecoder()
    }

    init(data: Data) throws {
        try self = Self.decoder().decode(Self.self, from: data)
    }
}

public typealias JSONBody = JSONEncodableBody & JSONDecodableBody
