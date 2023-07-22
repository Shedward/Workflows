//
//  ListBody.swift
//  Created by Vladislav Maltsev on 22.07.2023.
//

import Foundation

public struct ListBody<Item> {
    public let items: [Item]

    public init(items: [Item]) {
        self.items = items
    }
}

extension ListBody: RestBodyEncodable where Item: Encodable {
    public func data() throws -> Data? {
        try JSONEncoder().encode(items)
    }
}

extension ListBody: RestBodyDecodable where Item: Decodable {
    public static func fromData(_ data: Data) throws -> ListBody<Item> {
        let items = try JSONDecoder().decode([Item].self, from: data)
        return ListBody(items: items)
    }
}
