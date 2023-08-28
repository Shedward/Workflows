//
//  InMemoryCacheStorage.swift
//
//
//  Created by Vladislav Maltsev on 13.08.2023.
//

public actor InMemoryCacheStorage<Content>: CacheStorage {
    private var cachedValue: Content?

    public func load() async -> Content? {
        cachedValue
    }

    public func save(_ content: Content) async {
        self.cachedValue = content
    }

    public func invalidate() async {
        cachedValue = nil
    }
}

extension AnyCacheStorage {
    public static var inMemory: AnyCacheStorage<Content> {
        InMemoryCacheStorage().eraseToAnyStorage()
    }
}
