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

    func addPullRequestsResponse(
        owner: String,
        repoName: String,
        forQuery query: PullRequest.Query = .init(),
        pagination: Pagination,
        response: Result<[PullRequestResponse], Error>
    ) async {
        let firstPageFilter = RestRequestFilter<EmptyBody, ListBody<PullRequestResponse>>(
            method: .exact(.get),
            path: .exact("/repos/\(owner)/\(repoName)/pulls"),
            query: .exact(
                RestQuery()
                    .merging(with: query.asRestQuery())
                    .merging(with: pagination.asRestQuery())
            )
        )

        await restClient.addResponse(for: firstPageFilter, response: response.map { ListBody(items: $0) })
    }
    
    func addPullRequestsResponse(
        owner: String,
        repoName: String,
        forQuery query: PullRequest.Query = .init(),
        response: Result<[PullRequestResponse], Error>
    ) async {
        await addPullRequestsResponse(
            owner: owner,
            repoName: repoName,
            forQuery: query,
            pagination: Pagination(page: 0),
            response: response
        )
        
        if case .success = response {
            await addPullRequestsResponse(
                owner: owner,
                repoName: repoName,
                forQuery: query,
                pagination: Pagination(page: 1),
                response: .success([])
            )
        }
    }
}
