//
//  GitHubClient+Pulls.swift
//  Created by Vladislav Maltsev on 22.07.2023.
//

import RestClient

extension GitHubClient {

    func getPullRequests(
        owner: String,
        repoName: String,
        query: PullRequest.Query = .init(),
        pagination: Pagination? = nil
    ) async throws -> [PullRequestResponse] {
        let request = RestRequest<EmptyBody, ListBody<PullRequestResponse>>(
            method: .get,
            path: "/repos/\(owner)/\(repoName)/pulls",
            query: RestQuery
                .merging(with: query.asRestQuery())
                .merging(with: pagination?.asRestQuery())
        )
        let response = try await restClient.request(request)
        return response.items
    }
}
