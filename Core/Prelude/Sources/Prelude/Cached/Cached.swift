//
//  Cached.swift
//
//
//  Created by Vladislav Maltsev on 13.08.2023.
//

public struct Cached<Content> {
    public typealias Refresh = () async throws -> Content

    private let storage: AnyCacheStorage<Content>
    private let refresh: Refresh

    public init(storage: AnyCacheStorage<Content>, refresh: @escaping Refresh) {
        self.storage = storage
        self.refresh = refresh
    }

    @discardableResult
    public func reload() async throws -> Content {
        let value = try await refresh()
        await storage.save(value)
        return value
    }

    public func invalidate() async {
        await storage.invalidate()
    }

    public func load() async throws -> Content {
        if let cachedValue = await storage.load() {
            return cachedValue
        } else {
            let value = try await refresh()
            await storage.save(value)
            return value
        }
    }
}
