//
//  CachedTests.swift
//
//
//  Created by Vladislav Maltsev on 13.08.2023.
//

import XCTest
import Prelude

final class CachedTests: XCTestCase {

    private class NextNumberFetcher {
        var nextNumber: Int = 0

        func fetchNextNumber() -> Int {
            nextNumber += 1
            return nextNumber
        }
    }

    func testBasicUsage() async throws {
        let fetcher = NextNumberFetcher()
        
        let cachedNumber = Cached<Int>(storage: .inMemory) {
            fetcher.fetchNextNumber()
        }

        let firstLoad = try await cachedNumber.load()
        XCTAssertEqual(firstLoad, 1)

        let secondLoad = try await cachedNumber.load()
        XCTAssertEqual(secondLoad, 1)

        let reload = try await cachedNumber.reload()
        XCTAssertEqual(reload, 2)

        let thirdLoad = try await cachedNumber.load()
        XCTAssertEqual(thirdLoad, 2)

        await cachedNumber.invalidate()
        let forthLoad = try await cachedNumber.load()
        XCTAssertEqual(forthLoad, 3)
    }
}
