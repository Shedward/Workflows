//
//  FileManagerFileSystem.swift
//
//
//  Created by Vlad Maltsev on 24.10.2023.
//

import Foundation

public final class FileManagerFileSystem: FileSystem {
    private let fileManager: FileManager
    
    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }
    
    public func item(at path: Path) -> FileItem {
        FileItem(fileSystem: self, path: path)
    }
    
    public func items(at path: Path) throws -> [FileItem] {
        try fileManager.contentsOfDirectory(at: path.url, includingPropertiesForKeys: nil).map { url in
            item(at: Path(url: url))
        }
    }
    
    public func itemExists(at path: Path) -> Bool {
        fileManager.fileExists(atPath: path.string)
    }
    
    public func deleteItem(at path: Path) throws {
        try fileManager.removeItem(at: path.url)
    }
    
    public func loadData(at path: Path) throws -> Data {
        try Data(contentsOf: path.url)
    }
    
    public func save(data: Data, at path: Path) throws {
        try data.write(to: path.url)
    }
}
