//
//  RawJson.swift
//  API
//
//  Created by Vlad Maltsev on 08.01.2026.
//

import Core
import Foundation
import Rest

public struct RawJson: JSONBody {
    public let json: String

    init(json: String) {
        self.json = json
    }

    public init<Value: Encodable>(_ value: Value) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(value)
        guard let string = String(data: data, encoding: .utf8) else {
            throw Failure("Failed to encode \(data) to .utf8")
        }
        self.json = string
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.json = try container.decode(String.self)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.json)
    }

    public func decode<Value: Decodable>(_ type: Decodable.Type) throws -> Value {
        let decoder = JSONDecoder()
        guard let data = json.data(using: .utf8) else {
            throw Failure("Failed to decode \(json) as .utf8")
        }
        return try decoder.decode(Value.self, from: data)
    }
}
