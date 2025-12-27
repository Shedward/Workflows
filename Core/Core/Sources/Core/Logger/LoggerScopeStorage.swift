//
//  LoggerScopeStorage.swift
//  Core
//
//  Created by Vlad Maltsev on 08.12.2025.
//

import Foundation

final class LoggerScopeStorage: @unchecked Sendable {
    static let shared = LoggerScopeStorage()

    private var enabledScopes: Set<LoggerScope> = [.global, LoggerScope(name: "Debug")]
    private let lock = NSLock()

    func enable(_ scope: LoggerScope) {
        lock.lock()
        enabledScopes.insert(scope)
        lock.unlock()
    }

    func disable(_ scope: LoggerScope) {
        lock.lock()
        enabledScopes.remove(scope)
        lock.unlock()
    }

    func isEnabled(_ scope: LoggerScope) -> Bool {
        lock.lock()
        let result = enabledScopes.contains(scope)
        lock.unlock()
        return result
    }
}
