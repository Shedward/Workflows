//
//  FileCacheStorage.swift
//
//
//  Created by Vladislav Maltsev on 13.08.2023.
//

import Prelude
import Foundation
import os

public class FileCacheStorage<Content>: CacheStorage where Content: Codable {

    private let fileItem: FileItem
    private let logger = Logger(scope: .global)

    init(at fileItem: FileItem) {
        self.fileItem = fileItem
    }

    public func load() async -> Content? {
        guard fileItem.isExists else {
            return nil
        }

        do {
            return try fileItem.load()
        } catch {
            logger.error(
                """
                Failed to load cache from \(self.fileItem, privacy: .public):
                \(error, privacy: .public)
                """
            )
            return nil
        }
    }

    public func save(_ content: Content) async {
        do {
            try fileItem.save(content)
        } catch {
            logger.error(
                """
                Failed to save cache to \(self.fileItem, privacy: .public):
                \(error, privacy: .public)
                """
            )
        }
    }

    public func invalidate() async {
        guard fileItem.isExists else {
            return
        }
        
        do {
            try fileItem.delete()
        } catch {
            logger.error(
                """
                Failed to invalidate cache at \(self.fileItem, privacy: .public):
                \(error, privacy: .public)
                """
            )
        }
    }
}

extension AnyCacheStorage where Content: Codable {
    public static func file(_ item: FileItem) -> AnyCacheStorage<Content> {
        FileCacheStorage<Content>(at: item)
            .eraseToAnyStorage()
    }
}
