//
//  Logger.swift
//  Core
//
//  Created by Vlad Maltsev on 08.12.2025.
//

import os

public extension Logger {
    static let defaultSubsystemPrefix: String = "me.shedward.workflows"

    init?(subsystem: String = defaultSubsystemPrefix, scope: LoggerScope, prefix: String? = #fileID) {
        if LoggerScopeStorage.shared.isEnabled(scope) {
            var category = scope.name
            if let prefix {
                category += "." + prefix
            }

            self.init(subsystem: "\(Logger.defaultSubsystemPrefix).\(subsystem)", category: category)
        } else {
            return nil
        }
    }

    static func enable(_ scope: LoggerScope) {
        LoggerScopeStorage.shared.enable(scope)
    }

    static func disable(_ scope: LoggerScope) {
        LoggerScopeStorage.shared.disable(scope)
    }
}
