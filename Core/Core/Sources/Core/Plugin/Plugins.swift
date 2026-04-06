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

    public func all<Domain>(_ type: Domain.Type) -> [Domain] {
        objects.compactMap { $0 as? Domain }
    }

    @discardableResult
    public func invoke<Domain, Output>(
        _ type: Domain.Type, action: (Domain) throws -> Output
    ) rethrows -> [Output] {
        try all(Domain.self).map { domain in
            try action(domain)
        }
    }
}

extension Plugins: Defaultable {
    public init() {
        self.init(plugins: [])
    }
}
