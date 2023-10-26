//
//  InMemoryFileSystemTests.swift
//
//
//  Created by Vlad Maltsev on 27.10.2023.
//

@testable import FileSystem
import XCTest

final class InMemoryFileSystemTests: XCTestCase {
    
    func testEmptyFileSystem() throws {
        let fileSystem = InMemoryFileSystem()
        XCTAssertEqual(try fileSystem.items(at: "/").count, 0)
    }
}
