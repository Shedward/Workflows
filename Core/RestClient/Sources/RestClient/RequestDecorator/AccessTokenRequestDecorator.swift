//
//  AccessTokenRequestDecorator.swift
//
//
//  Created by v.maltsev on 23.08.2023.
//

public protocol AccessTokenAuthorizer {
    func accessToken() async throws -> String
}

public struct AccessTokenAuthorizerRequestDecorator: RequestDecorator {
    private let authorizer: AccessTokenAuthorizer

    public init(authorizer: AccessTokenAuthorizer) {
        self.authorizer = authorizer
    }

    public func request<Request, Response>(
        from request: RestRequest<Request, Response>
    ) async throws -> RestRequest<Request, Response> where Request : RestBodyEncodable, Response : RestBodyDecodable {
        let accessToken = try await authorizer.accessToken()
        var request = request
        request.headers.merge(.set("Authorization", to: "Bearer \(accessToken)"))
        return request
    }
}
