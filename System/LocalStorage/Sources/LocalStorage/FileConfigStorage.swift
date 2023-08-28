//
//  FileConfigStorage.swift
//
//
//  Created by v.maltsev on 28.08.2023.
//

import Foundation
import Prelude

public struct FileConfigStorage: ConfigStorage {

    private let configsDirectory: URL

    public init() {
        let homeDirectory = FileManager.default.homeDirectoryForCurrentUser
        let configsDirectory = homeDirectory.appending(path: ".workflows/configs")
        self.init(at: configsDirectory)
    }

    public init(at path: URL) {
        self.configsDirectory = path
    }

    public func load<T>(at name: String) throws -> T where T : Decodable {
        let fileUrl = configsDirectory.appending(component: name).appendingPathExtension("json")
        let data = try Failure.wrap("Loading file from \(fileUrl)") {
            try Data(contentsOf: fileUrl)
        }
        let config = try Failure.wrap("Decoding config") {
            try JSONDecoder().decode(T.self, from: data)
        }
        return config
    }
}
