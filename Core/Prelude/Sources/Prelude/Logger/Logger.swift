//
//  Logger.swift
//  Created by Vladislav Maltsev on 26.07.2023.
//

import os

public extension Logger {
    static var defaultSubsystemPrefix: String = "me.shedward.workflows"
    static var enabledScopes: [LoggerScope] = [.global, LoggerScope(name: "Debug")]

    init(subsystem: String = defaultSubsystemPrefix, scope: LoggerScope) {
        if Logger.enabledScopes.contains(scope) {
            self.init(subsystem: "\(Logger.defaultSubsystemPrefix).\(subsystem)", category: scope.name)
        } else {
            self.init(.disabled)
        }
    }
}
