//
//  ErrorDescription.swift
//  API
//
//  Created by Vlad Maltsev on 24.02.2026.
//

public struct ErrorDescription: Sendable, Codable {
    public let userDescription: String
    public let debugDescription: String

    public init(userDescription: String, debugDescription: String) {
        self.userDescription = userDescription
        self.debugDescription = debugDescription
    }
}
