//
//  DirectoryCodableStorage.swift
//
//
//  Created by v.maltsev on 28.08.2023.
//

import Foundation
import Prelude

public struct DirectoryCodableStorage: CodableStorage {

    private let directory: URL

    public init() {
        let homeDirectory = FileManager.default.homeDirectoryForCurrentUser
        let configsDirectory = homeDirectory.appending(path: ".workflows/configs")
        self.init(at: configsDirectory)
    }

    public init(at path: URL) {
        self.directory = path
    }

    public func load<T>(at key: String) throws -> T where T : Decodable {
        let fileUrl = self.fileUrl(at: key)
        let data = try Failure.wrap("Loading file from \(fileUrl)") {
            try Data(contentsOf: fileUrl)
        }
        let config = try Failure.wrap("Decoding config") {
            try JSONDecoder().decode(T.self, from: data)
        }
        return config
    }
    
    public func save<T>(_ value: T, at key: String) throws where T : Encodable {
        let fileUrl = self.fileUrl(at: key)
        let data = try Failure.wrap("Encoding value \(value)") {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            return try encoder.encode(value)
        }
        
        try Failure.wrap("Writing file to \(fileUrl)") {
            try data.write(to: fileUrl)
        }
    }
    
    private func fileUrl(at key: String) -> URL {
        directory.appending(component: key).appendingPathExtension("json")
    }
}
