//
//  PaginatingList.swift
//  Created by Vladislav Maltsev on 22.07.2023.
//

public struct PaginatingList<Item> {
    private let client: PaginatingClient<Item>
    private var currentPage: Int
    private var canLoadNextPage: Bool

    public private(set) var items: [Item] = []
    private let pageSize: Int?

    public init(client: PaginatingClient<Item>, pageSize: Int? = nil) {
        self.client = client
        self.pageSize = pageSize
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
        let newItems = try await page(currentPage, pageSize: pageSize)
        items.append(contentsOf: newItems)
        if newItems.isEmpty {
            canLoadNextPage = false
        }
    }

    public mutating func loadAll(limitCount: Int = .max) async throws {
        while canLoadNextPage && items.count < limitCount {
            try await loadNextPage()
        }
    }

    public func page(_ pageIndex: Int = 0, pageSize: Int?) async throws -> [Item] {
        try await client.fetchPage(currentPage, pageSize: pageSize ?? self.pageSize)
    }

    public func allItems(limitCount: Int = .max) async throws -> [Item] {
        var list = self
        try await list.loadAll(limitCount: limitCount)
        return list.items
    }

    public func withPageSize(_ pageSize: Int?) -> PaginatingList<Item> {
        .init(client: client, pageSize: pageSize)
    }
}