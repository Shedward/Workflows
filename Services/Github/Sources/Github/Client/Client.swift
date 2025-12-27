//
//  Client.swift
//  Github
//
//  Created by Vlad Maltsev on 23.12.2025.
//

import Foundation
import RestClient

public final class GithubClient {
    private let rest: RestClient

    public init() {
        let url = URL(string: "https://api.github.com")!
        let endpoint = NetworkRestClient.Endpoint(host: url)
        let authoriser = StaticTokenAuthorizer("<Token>")

        let headers = Headers()
            .set("Accept", to: "application/vnd.github+json")
            .set("X-GitHub-Api-Version", to: "2022-11-28")
            .set("User-Agent", to: "Workflows-App")

        self.rest = NetworkRestClient(
            endpoint: endpoint,
            requestDecorators: RequestDecoratorsSet()
                .addHeaders(headers)
                .authorizer(authoriser)
        )

    }

    public func fetch<Api: GithubApi>(_ api: Api) async throws -> Api.ResponseBody {
        try await rest.fetch(api.request)
    }
}
