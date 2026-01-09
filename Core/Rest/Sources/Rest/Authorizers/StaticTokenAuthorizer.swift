//
//  StaticTokenAuthorizer.swift
//  Rest
//
//  Created by Vlad Maltsev on 23.12.2025.
//

public struct StaticTokenAuthorizer: AccessTokenAuthorizer {
    public let token: String

    public init(_ token: String) {
        self.token = token
    }

    public func authorizationHeaders() async throws -> Headers {
        bearer(token)
    }
}
