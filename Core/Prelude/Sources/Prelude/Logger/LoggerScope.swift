//
//  LoggerScope.swift
//  Created by Vladislav Maltsev on 26.07.2023.
//

public struct LoggerScope: Equatable {
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
