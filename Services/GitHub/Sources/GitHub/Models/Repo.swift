//
//  Repo.swift
//  Created by Vladislav Maltsev on 22.07.2023.
//

import RestClient

public struct Repo {
    public let owner: String
    public let name: String

    private let client: GitHubClient

    init(owner: String, name: String, client: GitHubClient) {
        self.owner = owner
        self.name = name
        self.client = client
    }

    public func details() async throws -> RepoDetails {
        let repoResponse = try await client.getRepo(owner: owner, name: name)
        return RepoDetails(response: repoResponse, client: client)
    }

    public func pullRequests(query: PullRequest.Query = .init()) -> PaginatingList<PullRequest> {
        PaginatingList { pageId, pageSize in
            let pullRequestsResponses = try await client.getPullRequests(
                owner: owner,
                repoName: name,
                query: query,
                pagination: Pagination(page: pageId, perPage: pageSize)
            )

            let pullRequests = pullRequestsResponses.map { response in
                PullRequest(response: response, client: client)
            }

            return pullRequests
        }
    }
}
