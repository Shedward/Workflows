//
//  FileItem.swift
//
//
//  Created by Vlad Maltsev on 24.10.2023.
//

import Foundation

public struct FileItem {
    private let fileSystem: FileSystem
    private let path: Path
    
    init(fileSystem: FileSystem, path: Path) {
        self.fileSystem = fileSystem
        self.path = path
    }
    
    public func loadData() throws -> Data {
        try fileSystem.loadData(at: path)
    }
}
