//
//  FileCacheStorage.swift
//
//
//  Created by Vladislav Maltsev on 13.08.2023.
//

import Foundation
import os

public class FileCacheStorage<Content>: CacheStorage where Content: Codable {

    private let url: URL
    private let fileManager: FileManager
    private let logger = Logger(scope: .global)

    init(path: URL, fileManager: FileManager = .default) {
        self.url = path
        self.fileManager = fileManager
    }

    public func load() async -> Content? {
        guard fileManager.fileExists(atPath: url.path) else {
            return nil
        }

        do {
            let data = try Failure.wrap("Loading data from file") {
                try Data(contentsOf: url)
            }

            let model = try Failure.wrap("Parsing data") {
                try JSONDecoder().decode(Content.self, from: data)
            }

            return model
        } catch {
            logger.error(
                """
                Failed to load cache from \(self.url, privacy: .public):
                \(error, privacy: .public)
                """
            )
            return nil
        }
    }

    public func save(_ content: Content) async {
        do {
            let data = try Failure.wrap("Encoding data") {
                try JSONEncoder().encode(content)
            }
            try Failure.wrap("Saving data to file") {
                try data.write(to: self.url, options: .atomic)
            }
        } catch {
            logger.error(
                """
                Failed to save cache to \(self.url, privacy: .public):
                \(error, privacy: .public)
                """
            )
        }
    }

    public func invalidate() async {
        guard fileManager.fileExists(atPath: url.path) else {
            return
        }
        
        do {
            try fileManager.removeItem(at: url)
        } catch {
            logger.error(
                """
                Failed to invalidate cache at \(self.url, privacy: .public):
                \(error, privacy: .public)
                """
            )
        }
    }
}

extension AnyCacheStorage where Content: Codable {
    public static func file(_ path: URL) -> AnyCacheStorage<Content> {
        FileCacheStorage<Content>(path: path)
            .eraseToAnyStorage()
    }
}
