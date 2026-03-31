//
//  Plugin.swift
//  Core
//
//  Created by Мальцев Владислав on 31.03.2026.
//

public protocol Plugin {
    var manifest: PluginManifest { get }

    @ArrayBuilder<PluginObject>
    var objects: [PluginObject] { get }
}

public protocol PluginObject: Sendable {}

public struct PluginManifest: Codable {
    public let name: String
    public let version: Int

    public init(name: String, version: Int) {
        self.name = name
        self.version = version
    }
}
