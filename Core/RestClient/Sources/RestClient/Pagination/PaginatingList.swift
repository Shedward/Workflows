//
//  PaginatingList.swift
//  Created by Vladislav Maltsev on 22.07.2023.
//

public struct PaginatingList<Item> {
    public typealias FetchBlock = (Int, Int?) async throws -> [Item]

    private let fetch: FetchBlock
    private var currentPage: Int
    private var canLoadNextPage: Bool

    public private(set) var items: [Item] = []
    private let pageSize: Int?

    public init(pageSize: Int? = nil, fetch: @escaping FetchBlock) {
        self.fetch = fetch
        self.pageSize = pageSize
        self.currentPage = 0
        self.canLoadNextPage = true
    }

    public mutating func reset() {
        items = []
        currentPage = 0
        canLoadNextPage = true
    }

    public mutating func reload() async throws {
        reset()
        try await loadNextPage()
    }

    public mutating func loadNextPage() async throws {
        guard canLoadNextPage else { return }

        let newItems = try await page(currentPage, pageSize: pageSize)
        items.append(contentsOf: newItems)
        if newItems.isEmpty {
            canLoadNextPage = false
        }
        currentPage += 1
    }

    public mutating func loadAll(maxCount: Int = .max) async throws {
        while canLoadNextPage && items.count < maxCount {
            try await loadNextPage()
        }
    }

    public func page(_ pageIndex: Int, pageSize: Int? = nil) async throws -> [Item] {
        try await fetch(pageIndex, pageSize ?? self.pageSize)
    }

    public func allItems(maxCount: Int = .max) async throws -> [Item] {
        var list = self
        try await list.loadAll(maxCount: maxCount)
        return list.items
    }

    public func withPageSize(_ pageSize: Int?) -> PaginatingList<Item> {
        .init(pageSize: pageSize, fetch: fetch)
    }

    public func map<OtherItem>(_ transform: @escaping (Item) throws -> OtherItem) rethrows -> PaginatingList<OtherItem> {
        var otherList = PaginatingList<OtherItem>(pageSize: pageSize) { page, pageSize in
            let newItems = try await fetch(page, pageSize)
            let newOtherItems = try newItems.map(transform)
            return newOtherItems
        }

        otherList.items = try items.map(transform)
        otherList.currentPage = currentPage
        otherList.canLoadNextPage = canLoadNextPage

        return otherList
    }
}
