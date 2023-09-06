//
//  IssueResponse.swift
//  Created by Vladislav Maltsev on 26.07.2023.
//

import Prelude
import RestClient
import Foundation

struct IssueResponse<Fields>: JSONDecodableBody, Sendable where Fields: Decodable, Fields: Sendable {
    let id: String
    let key: String
    let fields: Fields

    enum CodingKeys: CodingKey {
        case id
        case key
        case fields
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.key = try container.decode(String.self, forKey: .key)
        self.fields = try container.decodeVoidable(Fields.self, forKey: .fields)
    }
}
