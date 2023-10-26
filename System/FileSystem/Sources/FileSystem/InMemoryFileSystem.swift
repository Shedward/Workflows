//
//  InMemoryFileSystem.swift
//
//
//  Created by Vlad Maltsev on 26.10.2023.
//

import Foundation

enum InMemoryFileItem {
    case directory
    case file(Data)
}

enum InMemoryFileSystemError: Error {
    case fileNotFound
    case noDirectory
    case itemIsNotFile
}

public final class InMemoryFileSystem: FileSystem {
    
    private var items: [Path: InMemoryFileItem]
    
    init(items: [Path: InMemoryFileItem] = [:]) {
        self.items = items
    }
    
    public func item(at path: Path) -> FileItem {
        FileItem(fileSystem: self, path: path)
    }
    
    public func items(at path: Path) throws -> [FileItem] {
        items
            .filter { key, _ in
                key.string.starts(with: path.string)
            }
            .map { FileItem(fileSystem: self, path: $0.key) }
    }
    
    public func itemExists(at path: Path) -> Bool {
        items[path] != nil
    }
    
    public func deleteItem(at path: Path) throws {
        guard itemExists(at: path) else {
            throw InMemoryFileSystemError.fileNotFound
        }
        
        items[path] = nil
    }
    
    public func loadData(at path: Path) throws -> Data {
        guard let item = items[path] else {
            throw InMemoryFileSystemError.fileNotFound
        }
        
        guard case .file(let data) = item else {
            throw InMemoryFileSystemError.itemIsNotFile
        }
        
        return data
    }
    
    public func save(data: Data, at path: Path) throws {
        guard haveDirectory(at: path) else {
            throw InMemoryFileSystemError.noDirectory
        }
        
        items[path] = .file(data)
    }
    
    private func haveDirectory(at path: Path) -> Bool {
        if case .some(.file) = items[path] {
            return false
        }
        
        return items.contains { key, item in
            key.string.starts(with: path.string)
        }
    }
}
