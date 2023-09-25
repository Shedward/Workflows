//
//  GitHubClient+Pulls.swift
//  Created by Vladislav Maltsev on 22.07.2023.
//

import Prelude
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
            query: RestQuery()
                .merging(with: query.asRestQuery())
                .merging(with: pagination?.asRestQuery())
        )
        let response = try await restClient.request(request)
        return response.items
    }
}

extension GitHubMock {

    func setPullRequestsResponse(
        owner: String,
        repoName: String,
        forQuery query: PullRequest.Query = .init(),
        response: Result<[PullRequestResponse], Error>
    ) async {
        let filter = RestRequestFilter<EmptyBody, ListBody<PullRequestResponse>>(
            method: .exact(.get),
            path: .exact("/repos/\(owner)/\(repoName)/pulls"),
            query: .exact(query.asRestQuery(), forKeys: PullRequest.Query.restQueryKeys())
        )

        await restClient.addHandler(for: filter) { request in
            let pagination = try? Pagination(restQuery: request.query)

            let currentPage = pagination?.page ?? 0

            if currentPage == 0 {
                return ListBody(items: try response.get())
            } else {
                return ListBody(items: [])
            }
        }
    }
}
