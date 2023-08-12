//
//  PaginatingListTests.swift
//  Workflows
//
//  Created by Vladislav Maltsev on 30.07.2023.
//

import RestClient
import XCTest

final class PaginatingListTests: XCTestCase {

    private struct PaginatingItemsGenerator {
        var maxCount: Int

        func page(_ pageIndex: Int, pageSize: Int) -> [Int] {
            let startValue = pageIndex * pageSize + 1
            guard startValue <= maxCount else { return [] }
            let endValue = min(startValue + pageSize - 1, maxCount)
            return Array(startValue...endValue)
        }
    }

    func testEmptyList() async throws {
        let paginatingList = PaginatingList<Int> { page, pageSize in
            []
        }

        let firstPage = try await paginatingList.page(0)
        XCTAssertEqual(firstPage.count, 0)

        let allItems = try await paginatingList.allItems()
        XCTAssertEqual(allItems.count, 0)
    }

    private func testingPaginatingList() -> PaginatingList<Int> {
        PaginatingList<Int> { page, pageSize in
            PaginatingItemsGenerator(maxCount: 10).page(page, pageSize: pageSize ?? 3)
        }
    }

    func testPageLoading() async throws {
        let paginatingList = testingPaginatingList()

        let firstPage = try await paginatingList.page(0)
        XCTAssertEqual(firstPage, [1, 2, 3])

        let secondPage = try await paginatingList.page(1)
        XCTAssertEqual(secondPage, [4, 5, 6])

        let allItems = try await paginatingList.allItems()
        XCTAssertEqual(allItems, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
    }

    func testMutatingLoading() async throws {
        var paginatingList = testingPaginatingList()

        try await paginatingList.loadNextPage()
        XCTAssertEqual(paginatingList.items, [1, 2, 3])

        try await paginatingList.loadNextPage()
        XCTAssertEqual(paginatingList.items, [1, 2, 3, 4, 5, 6])

        try await paginatingList.loadAll()
        XCTAssertEqual(paginatingList.items, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10])

        try await paginatingList.reload()
        XCTAssertEqual(paginatingList.items, [1, 2, 3])
    }

    func testPageSizeReshape() async throws {
        let paginatingList = testingPaginatingList()

        let biggerPageList = paginatingList.withPageSize(8)

        let firstPage = try await biggerPageList.page(0)
        XCTAssertEqual(firstPage, [1, 2, 3, 4, 5, 6, 7, 8])

        let secondPage = try await biggerPageList.page(1)
        XCTAssertEqual(secondPage, [9, 10])
    }
}
