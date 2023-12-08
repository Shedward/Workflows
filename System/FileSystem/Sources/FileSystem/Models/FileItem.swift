//
//  FileItem.swift
//
//
//  Created by Vlad Maltsev on 24.10.2023.
//

import Foundation
import os

public struct FileItem {
    private let fileSystem: FileSystem
    let path: Path
    
    init(fileSystem: FileSystem, path: Path) {
        self.fileSystem = fileSystem
        self.path = path
    }
    
    public var isExists: Bool {
        fileSystem.itemExists(at: path)
    }
    
    public var name: String {
        path.url.lastPathComponent.removingPercentEncoding ?? "<failed-to-removed-percent-encoding>"
    }
    
    public func parrent() throws -> FileItem {
        let path = self.path.dropLast()
        return FileItem(fileSystem: fileSystem, path: path)
    }
    
    public func load() throws -> Data {
        try fileSystem.loadData(at: path)
    }
    
    public func save(_ data: Data) throws {
        try fileSystem.save(data: data, at: path)
    }
    
    public func appending(_ subpath: String) -> FileItem {
        let path = self.path.appending(subpath)
        return FileItem(fileSystem: fileSystem, path: path)
    }

    public func childs() throws -> [FileItem] {
        try fileSystem.items(in: path)
    }
    
    public func delete() throws {
        try fileSystem.deleteItem(at: path)
    }
    
    public func createDirectory() throws {
        try fileSystem.createDirectory(at: path)
    }
}

extension FileItem: CustomStringConvertible {
    public var description: String {
        "FileItem(fileSystem: \(fileSystem), path: \(path.string))"
    }
}

extension FileItem {
    
    public func load<T: Decodable>(type: T.Type, decoder: JSONDecoder = JSONDecoder()) throws -> T {
        try load()
    }
    
    public func load<T: Decodable>(decoder: JSONDecoder = JSONDecoder()) throws -> T {
        let data: Data = try load()
        let value = try decoder.decode(T.self, from: data)
        return value
    }
    
    public func save<T: Encodable>(_ value: T, encoder: JSONEncoder = JSONEncoder()) throws {
        let data = try encoder.encode(value)
        try save(data)
    }
}
