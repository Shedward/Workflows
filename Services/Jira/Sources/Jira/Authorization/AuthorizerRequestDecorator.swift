//
//  AuthorizerRequestDecorator.swift
//
//
//  Created by v.maltsev on 03.09.2023.
//

import RestClient

struct AuthorizerRequestDecorator: RequestDecorator {
    private let authorizer: JiraAuthorizer

    init(authorizer: JiraAuthorizer) {
        self.authorizer = authorizer
    }

    func request<Request, Response>(
        from request: RestRequest<Request, Response>
    ) async throws -> RestRequest<Request, Response> where Request : RestBodyEncodable, Response : RestBodyDecodable {
        let token = try authorizer.creds().token()

        var request = request
        request.headers.merge(RestHeaders.set("Authorization", to: "Basic \(token)"))
        return request
    }
}
