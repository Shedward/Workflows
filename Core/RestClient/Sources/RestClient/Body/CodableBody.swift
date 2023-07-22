//
//  CodableBody.swift
//  Created by Vladislav Maltsev on 18.07.2023.
//

import Foundation

public extension RestBodyEncodable where Self: Encodable {
    func data() throws -> Data? {
        try JSONEncoder().encode(self)
    }
}

public extension RestBodyDecodable where Self: Decodable {
    static func fromData(_ data: Data) throws -> Self {
        try JSONDecoder().decode(Self.self, from: data)
    }
}
