//
//  FileManagerFileSystem.swift
//
//
//  Created by Vlad Maltsev on 24.10.2023.
//

import Foundation

public final class FileManagerFileSystem: FileSystem {
    private let fileManager: FileManager
    
    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }
    
    public func homeDirectory() -> FileItem {
        let path = Path(url: fileManager.homeDirectoryForCurrentUser)
        return FileItem(fileSystem: self, path: path)
    }
    
    public func temporaryDirectory() -> FileItem {
        let directory = NSTemporaryDirectory()
        let temporaryUrl = URL(filePath: directory)
        return FileItem(fileSystem: self, path: Path(url: temporaryUrl))
    }
    
    public func item(at path: Path) -> FileItem {
        FileItem(fileSystem: self, path: path)
    }
    
    public func items(in path: Path) throws -> [FileItem] {
        try fileManager.contentsOfDirectory(at: url(path), includingPropertiesForKeys: nil).map { url in
            item(at: self.path(url))
        }
    }
    
    public func itemExists(at path: Path) -> Bool {
        fileManager.fileExists(atPath: path.string)
    }
    
    public func deleteItem(at path: Path) throws {
        try fileManager.removeItem(at: url(path))
    }
    
    public func createDirectory(at path: Path) throws {
        try fileManager.createDirectory(atPath: path.string, withIntermediateDirectories: true)
    }
    
    public func loadData(at path: Path) throws -> Data {
        try Data(contentsOf: url(path))
    }
    
    public func save(data: Data, at path: Path) throws {
        try data.write(to: url(path))
    }
    
    private func url(_ path: Path) -> URL {
        URL(fileURLWithPath: path.string)
    }
    
    private func path(_ url: URL) -> Path {
        Path(url.path(percentEncoded: false))
    }
}
