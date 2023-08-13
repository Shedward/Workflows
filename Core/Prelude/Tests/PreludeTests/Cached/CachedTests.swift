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

    func testInMemoryBasicUsage() async throws {
        try await testBasicUsage(storage: .inMemory)
    }

    func testFileBasicUsage() async throws {
        let tempFile = try uniqueTempFile("TestFileBasicUsage", ext: "json")
        try await testBasicUsage(storage: .file(tempFile))
    }

    private func uniqueTempFile(_ name: String, ext: String) throws -> URL {
        let prefix = "WorkflowTests/caches"
        let dirPath = FileManager.default.temporaryDirectory.appending(path: prefix)
        if !FileManager.default.fileExists(atPath: dirPath.absoluteString) {
            try FileManager.default.createDirectory(at: dirPath, withIntermediateDirectories: true)
        }
        let uniqueName = "\(name).\(UUID().uuidString).\(ext)"
        let path = dirPath.appending(path: uniqueName)
        return path
    }

    func testBasicUsage(storage: AnyCacheStorage<Int>) async throws {
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
