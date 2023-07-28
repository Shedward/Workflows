//
//  PageResponse.swift
//  Created by Vladislav Maltsev on 27.07.2023.
//

import Prelude
import RestClient

protocol PageResponseDynamicKeys {
    static var items: ArbitraryCodingKey { get }
}

struct PageResponse<Item, DynamicKeys>: Decodable, RestBodyDecodable, Sendable
    where Item: Decodable, Item: Sendable, DynamicKeys: PageResponseDynamicKeys {

    let startAt: Int
    let maxResults: Int
    let total: Int
    let items: [Item]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ArbitraryCodingKey.self)
        self.startAt = try container.decode(Int.self, forKey: PageResponseCodingKeys.startAt)
        self.maxResults = try container.decode(Int.self, forKey: PageResponseCodingKeys.maxResults)
        self.total = try container.decode(Int.self, forKey: PageResponseCodingKeys.total)
        self.items = try container.decode([Item].self, forKey: DynamicKeys.items)
    }
}

private enum PageResponseCodingKeys {
    static let startAt = ArbitraryCodingKey(stringValue: "startAt")
    static let maxResults = ArbitraryCodingKey(stringValue: "maxResults")
    static let total = ArbitraryCodingKey(stringValue: "total")
}
