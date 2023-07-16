//
//  EmptyBody.swift
//  Created by Vladislav Maltsev on 17.07.2023.
//

import Foundation

protocol RestBodyEncodable {
    func data(encoder: JSONEncoder) throws -> Data?
}

protocol RestBodyDecodable {
    static func fromData(_ data: Data, decoder: JSONDecoder) throws -> Self
}

typealias RestBodyCodable = RestBodyEncodable & RestBodyDecodable

struct EmptyBody: RestBodyCodable {
    static func fromData(_ data: Data, decoder: JSONDecoder) -> EmptyBody {
        EmptyBody()
    }

    func data(encoder: JSONEncoder) -> Data? {
        nil
    }
}

extension RestBodyEncodable where Self: Encodable {
    func data(encoder: JSONEncoder) throws -> Data? {
        try encoder.encode(self)
    }
}

extension RestBodyDecodable where Self: Decodable {
    static func fromData(_ data: Data, decoder: JSONDecoder) throws -> Self {
        try decoder.decode(Self.self, from: data)
    }
}


