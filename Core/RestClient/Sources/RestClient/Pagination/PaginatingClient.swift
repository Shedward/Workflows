//
//  PaginatingClient.swift
//  Created by Vladislav Maltsev on 22.07.2023.
//

import Prelude

open class PaginatingClient<Item> {
    func fetchPage(_ pageIndex: Int) async throws -> [Item] {
        throw Failure("Not implemented")
    }
}

public final class BlockPaginatingClient<Item>: PaginatingClient<Item> {
    public typealias FetchBlock = (Int) async throws -> [Item]

    private let fetch: FetchBlock

    public init(_ fetch: @escaping FetchBlock) {
        self.fetch = fetch
    }

    public override func fetchPage(_ pageIndex: Int) async throws -> [Item] {
        try await fetch(pageIndex)
    }
}
