//
//  LoggerScope.swift
//  Core
//
//  Created by Vlad Maltsev on 08.12.2025.
//

public struct LoggerScope: Hashable, Sendable {
    public let name: String

    public init(name: String) {
        self.name = name
    }

    @available(*, deprecated, message: "For debug purposes, should not be commited")
    public static let debug = LoggerScope(name: "Debug")

    public static let global = LoggerScope(name: "Global")

    public static func file(_ fileID: StaticString = #fileID) -> LoggerScope {
        LoggerScope(name: "\(fileID)")
    }
}
