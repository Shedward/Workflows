//
//  AnyCacheStorage.swift
//
//
//  Created by Vladislav Maltsev on 13.08.2023.
//

public struct AnyCacheStorage<Content>: CacheStorage {
    private let loadAction: () async -> Content?
    private let saveAction: (Content) async -> Void
    private let invalidateAction: () async -> Void

    public init<Wrapped: CacheStorage>(_ wrapped: Wrapped) where Wrapped.Content == Content {
        self.loadAction = wrapped.load
        self.saveAction = wrapped.save(_:)
        self.invalidateAction = wrapped.invalidate
    }

    public func load() async -> Content? {
        await loadAction()
    }

    public func save(_ content: Content) async {
        await saveAction(content)
    }

    public func invalidate() async {
        await invalidateAction()
    }
}

extension CacheStorage {
    public func eraseToAnyStorage() -> AnyCacheStorage<Content> {
        AnyCacheStorage(self)
    }
}
