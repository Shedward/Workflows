//
//  LoggerScope.swift
//  Created by Vladislav Maltsev on 26.07.2023.
//

public struct LoggerScope: Equatable {
    public let name: String

    public init(name: String) {
        self.name = name
    }

    public static let global = LoggerScope(name: "global")

    public static func file(_ fileID: StaticString = #fileID) -> LoggerScope {
        LoggerScope(name: "\(fileID)")
    }
}
