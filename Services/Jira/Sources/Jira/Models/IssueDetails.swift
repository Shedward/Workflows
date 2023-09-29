//
//  IssueDetails.swift
//  Created by Vladislav Maltsev on 26.07.2023.
//

import Prelude
import RestClient
import Foundation

public struct IssueDetails<Fields>: JSONDecodableBody, Sendable where Fields: Decodable, Fields: Sendable {
    public let id: String
    public let key: String
    public let fields: Fields
    
    init(id: String, key: String, fields: Fields) {
        self.id = id
        self.key = key
        self.fields = fields
    }

    internal enum CodingKeys: CodingKey {
        case id
        case key
        case fields
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.key = try container.decode(String.self, forKey: .key)
        self.fields = try container.decodeVoidable(Fields.self, forKey: .fields)
    }
}
