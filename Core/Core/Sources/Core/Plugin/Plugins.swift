//
//  Plugins.swift
//  Core
//
//  Created by Мальцев Владислав on 31.03.2026.
//

public actor Plugins {
    private let plugins: [any Plugin]
    private let objects: [PluginObject]

    public init(plugins: [any Plugin]) {
        self.plugins = plugins
        self.objects = plugins.flatMap(\.objects)
    }

    public init(@ArrayBuilder<any Plugin> builder: () -> [any Plugin]) {
        self.init(plugins: builder())
    }

    public func all<D>(_ type: D.Type) -> [D] {
        objects.compactMap { $0 as? D }
    }

    @discardableResult
    public func invoke<D, Output>(
        _ type: D.Type, action: (D) throws -> Output
    ) rethrows -> [Output] {
        try all(D.self).map { domain in
            try action(domain)
        }
    }
}

extension Plugins: Defaultable {
    public init() {
        self.init(plugins: [])
    }
}
