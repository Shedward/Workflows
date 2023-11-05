//
//  FileCacheStorageTests.swift
//
//
//  Created by Vlad Maltsev on 05.11.2023.
//

@testable import FileSystem
import XCTest
import Prelude
import TestsPrelude

final class FileCacheStorageTests: XCTestCase {
    private class NextNumberFetcher {
        var nextNumber: Int = 0

        func fetchNextNumber() -> Int {
            nextNumber += 1
            return nextNumber
        }
    }

    func testFileBasicUsage() async throws {
        let fileSystem = InMemoryFileSystem()
        let cacheFile = fileSystem.item(at: "/mock.json")
        let storage = AnyCacheStorage<Int>.file(cacheFile)
        let fetcher = NextNumberFetcher()
        
        let cachedNumber = Cached<Int>(storage: storage) {
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
