//
//  GitHubClient.swift
//  Created by Vladislav Maltsev on 22.07.2023.
//

import RestClient
import Foundation

final class GitHubClient {
    let restClient: RestClient

    init(token: String) {
        let endpoint = RestEndpoint(host: URL(string: "https://api.github.com")!)
        restClient = NetworkRestClient(
            endpoint: endpoint,
            requestDecorators: [
                HeadersRequestDecorator(
                    headers: RestHeaders
                        .set("Accept", to: "application/vnd.github+json")
                        .set("Authorization", to: "Bearer \(token)")
                        .set("X-GitHub-Api-Version", to: "2022-11-28")
                )
            ]
        )
    }

    init(mock: GitHubMock) {
        restClient = mock.mockRestClient
    }
}
