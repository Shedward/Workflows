//
//  ErrorDescription.swift
//  API
//
//  Created by Vlad Maltsev on 24.02.2026.
//

import Core

public struct ErrorDescription: Sendable, Codable {
    public let userDescription: String
    public let debugDescription: String

    public init(userDescription: String, debugDescription: String) {
        self.userDescription = userDescription
        self.debugDescription = debugDescription
    }

    public init(error: any Error) {
        if let descriptiveError = error as? DescriptiveError {
            self.init(
                userDescription: descriptiveError.userDescription,
                debugDescription: String(describing: error)
            )
        } else {
            self.init(
                userDescription: error.localizedDescription,
                debugDescription: String(describing: error)
            )
        }
    }
}
