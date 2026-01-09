//
//  Authorizer.swift
//  Rest
//
//  Created by Vlad Maltsev on 23.12.2025.
//

public protocol AccessTokenAuthorizer: Sendable {
    func authorizationHeaders() async throws -> Headers
}

extension AccessTokenAuthorizer {
    public func simple(_ simpleToken: String) -> Headers {
        Headers("Authorization", to: "Simple \(simpleToken)")
    }

    public func bearer(_ bearerToken: String) -> Headers {
        Headers("Authorization", to: "Bearer \(bearerToken)")
    }
}
