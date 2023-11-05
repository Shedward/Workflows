//
//  InMemoryFileSystem.swift
//
//
//  Created by Vlad Maltsev on 26.10.2023.
//

import Foundation
import Prelude
import os

public enum InMemoryFileItem {
    case directory
    case file(Data)
}

enum InMemoryFileSystemError: Error {
    case fileNotFound
    case noDirectory
    case itemIsNotFile
    case cantCreateFolder(Path)
}

public final class InMemoryFileSystem: FileSystem {
    
    var items: [Path: InMemoryFileItem]
    
    public init(items: [Path: InMemoryFileItem] = [:]) {
        var items = items
        items["/"] = .directory
        self.items = items
    }
    
    public func item(at path: Path) -> FileItem {
        FileItem(fileSystem: self, path: path)
    }
    
    public func items(in path: Path) throws -> [FileItem] {
        let path = path.normalizeAsDirectory()
        guard haveDirectory(at: path) else {
            throw InMemoryFileSystemError.noDirectory
        }
        
        return items
            .filter { key, _ in
                key.dropLast() == path
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
        
        items = items.filter { currentPath, _ in
            !currentPath.string.starts(with: path.string) &&
            currentPath != path
        }
    }
    
    public func createDirectory(at path: Path) throws {
        let components = path.string.split(separator: "/")
        
        for index in components.indices {
            let pathString = components[...index].joined(separator: "/")
            let subpath = Path("/" + pathString + "/")
            if let item = items[subpath] {
                switch item {
                case .directory:
                    continue
                case .file:
                    throw InMemoryFileSystemError.cantCreateFolder(subpath)
                }
            } else {
                items[subpath] = .directory
            }
        }
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
        guard haveDirectory(at: path.dropLast()) else {
            throw InMemoryFileSystemError.noDirectory
        }
        
        items[path] = .file(data)
    }
    
    private func haveFile(at path: Path) -> Bool {
        if case .some(.file) = items[path] {
            true
        } else {
            false
        }
    }
    
    private func haveDirectory(at path: Path) -> Bool {
        if case .some(.directory) = items[path] {
            true
        } else {
            false
        }
    }
}
