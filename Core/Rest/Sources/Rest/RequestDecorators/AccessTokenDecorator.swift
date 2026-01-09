//
//  AccessTokenDecorator.swift
//  Rest
//
//  Created by Vlad Maltsev on 21.12.2025.
//

import Core

public struct AccessTokenDecorator: RequestDecorator {
    private let authorizer: AccessTokenAuthorizer

    public init(authorizer: AccessTokenAuthorizer) {
        self.authorizer = authorizer
    }

    public func decorate<RequestBody, ResponseBody>(
        _ request: Request<RequestBody, ResponseBody>
    ) async throws -> Request<RequestBody, ResponseBody> {
        guard request.metadata[NeedAuthorizedMetadataKey.self] else {
            return request
        }

        let authorizationHeaders = try await authorizer.authorizationHeaders()
        return request.with { $0.headers.merge(authorizationHeaders) }
    }
}

extension RequestDecoratorsSet {
    public func authorizer(_ authorizer: AccessTokenAuthorizer) -> Self {
        appending(AccessTokenDecorator(authorizer: authorizer))
    }
}
