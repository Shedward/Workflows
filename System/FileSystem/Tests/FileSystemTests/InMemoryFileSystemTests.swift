//
//  InMemoryFileSystemTests.swift
//
//
//  Created by Vlad Maltsev on 27.10.2023.
//

@testable import FileSystem
import XCTest
import TestsPrelude

final class InMemoryFileSystemTests: XCTestCase {
    
    private let mockData = "Mock".data(using: .utf8)!
    
    func testEmptyFileSystem() throws {
        let fileSystem = InMemoryFileSystem()
        XCTAssertEqual(try fileSystem.items(in: "/").count, 0)
    }
    
    func testCreateAndReadFile() throws {
        let fileSystem = InMemoryFileSystem()
        try fileSystem.createDirectory(at: "/root/child")
        try fileSystem.save(data: mockData, at: "/root/child/mock.txt")
        
        XCTAssertEqual(fileSystem.itemExists(at: "/root/child/mock.txt"), true)
        _ = try fileSystem.loadData(at: "/root/child/mock.txt")
    }
    
    func testNotExistingFile() throws {
        let fileSystem = InMemoryFileSystem()
        XCTAssertEqual(fileSystem.itemExists(at: "/root/child/notExists.txt"), false)
        XCTExpectThrow {
            _ = try fileSystem.loadData(at: "/root/child/notExists.txt")
        }
    }
    
    func testCanNotCreateFileWithoutFolder() throws {
        let fileSystem = InMemoryFileSystem()
        
        XCTExpectThrow {
            try fileSystem.save(data: mockData, at: "/root/child/mock.txt")
        }
    }
    
    func testListFiles() throws {
        let fileSystem = InMemoryFileSystem()
        try fileSystem.createDirectory(at: "/root/child")
        
        try fileSystem.save(data: mockData, at: "/root/child/file1.txt")
        try fileSystem.save(data: mockData, at: "/root/child/file2.txt")
        try fileSystem.save(data: mockData, at: "/root/child/file3.txt")
        
        try fileSystem.createDirectory(at: "/root/child/subchild")
        
        
        let items = try fileSystem.items(in: "/root/child")
        XCTAssertEqual(items.count, 4)
    }
}
