//
//  Repo.swift
//  Created by Vladislav Maltsev on 22.07.2023.
//

import RestClient

public struct Repo {
    public let id: Int
    public let owner: String
    public let name: String
    public let description: String

    private let client: GitHubClient

    init(response: RepoResponse, client: GitHubClient) {
        self.id = response.id
        self.owner = response.owner
        self.name = response.name
        self.description = response.description
        self.client = client
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
