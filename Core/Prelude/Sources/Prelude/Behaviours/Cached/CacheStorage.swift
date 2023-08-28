//
//  CacheStorage.swift
//
//
//  Created by Vladislav Maltsev on 13.08.2023.
//

public protocol CacheStorage {
    associatedtype Content

    func load() async -> Content?
    func save(_ content: Content) async

    func invalidate() async
}
