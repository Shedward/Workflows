//
//  Logger.swift
//  Core
//
//  Created by Vlad Maltsev on 08.12.2025.
//

import os

public extension Logger {
    static let defaultSubsystemPrefix: String = "me.shedward.workflows"

    static func enable(_ scope: LoggerScope) {
        LoggerScopeStorage.shared.enable(scope)
    }

    static func disable(_ scope: LoggerScope) {
        LoggerScopeStorage.shared.disable(scope)
    }

    init?(subsystem: String? = nil, scope: LoggerScope, prefix: String? = #fileID) {
        if LoggerScopeStorage.shared.isEnabled(scope) {
            var category = scope.name
            if let prefix {
                category += "." + prefix
            }

            let subsystem = [Logger.defaultSubsystemPrefix, subsystem].compactMap(\.self).joined(separator: ".")
            self.init(subsystem: subsystem, category: category)
        } else {
            return nil
        }
    }
}
