//
//  LoggerScopes.swift
//  Created by Vladislav Maltsev on 26.07.2023.
//

import Prelude

public extension LoggerScope {
    static let network = LoggerScope(name: "Network")
    static let mocks = LoggerScope(name: "Mocks")
}
