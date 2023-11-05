//
//  DirectoryCodableStorage.swift
//
//
//  Created by v.maltsev on 28.08.2023.
//

import Foundation
import Prelude
import FileSystem

public struct DirectoryCodableStorage: CodableStorage {

    private let directory: FileItem

    public init(at directory: FileItem) {
        self.directory = directory
    }

    public func load<T>(at key: String) throws -> T where T : Decodable {
        let fileItem = self.item(at: key)
        return try fileItem.load()
    }
    
    public func save<T>(_ value: T, at key: String) throws where T : Encodable {
        let fileItem = self.item(at: key)
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        try fileItem.save(value, encoder: encoder)
    }
    
    private func item(at key: String) -> FileItem {
        directory.appending(key + ".json")
    }
}
