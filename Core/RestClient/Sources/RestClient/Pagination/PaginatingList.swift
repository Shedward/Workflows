//
//  PaginatingList.swift
//  Created by Vladislav Maltsev on 22.07.2023.
//

public struct PaginatingList<Item> {
    private let client: PaginatingClient<Item>
    private var currentPage: Int
    private var canLoadNextPage: Bool

    public private(set) var items: [Item] = []

    public init(client: PaginatingClient<Item>) {
        self.client = client
        self.currentPage = 0
        self.canLoadNextPage = true
    }

    public mutating func reload() async throws {
        items = []
        currentPage = 0
        canLoadNextPage = true
        try await loadNextPage()
    }

    public mutating func loadNextPage() async throws {
        guard canLoadNextPage else { return }

        currentPage += 1
        let newItems = try await client.fetchPage(currentPage)
        items.append(contentsOf: newItems)
        if newItems.isEmpty {
            canLoadNextPage = false
        }
    }

    public mutating func loadAll() async throws {
        while canLoadNextPage {
            try await loadNextPage()
        }
    }

    public func firstPage() async throws -> [Item] {
        var list = self
        try await list.reload()
        return list.items
    }

    public func allItems() async throws -> [Item] {
        var list = self
        try await list.loadAll()
        return list.items
    }
}
