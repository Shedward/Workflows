//
//  ListBody.swift
//  Rest
//
//  Created by Vlad Maltsev on 21.12.2025.
//

import Foundation

public struct ListBody<Item> {
    public let items: [Item]

    public init(items: [Item]) {
        self.items = items
    }
}

extension ListBody: Sendable where Item: Sendable {}

extension ListBody: DataEncodable where Item: Encodable {
    public func data() throws -> Data? {
        try JSONEncoder().encode(items)
    }
}

extension ListBody: DataDecodable where Item: Decodable {
    public init(data: Data) throws {
        let items = try JSONDecoder().decode([Item].self, from: data)
        self.init(items: items)
    }
}
