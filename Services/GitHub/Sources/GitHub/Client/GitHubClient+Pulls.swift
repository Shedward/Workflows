//
//  GitHubClient+Pulls.swift
//  Created by Vladislav Maltsev on 22.07.2023.
//

import RestClient

extension GitHubClient {
    struct PullRequestQuery: RestQueryConvertible {
        enum State: String {
            case open
            case closed
            case all
        }

        var state: State = .open
        var base: String?
        var head: String?

        func asRestQuery() -> RestQuery {
            RestQuery
                .set("state", to: state.rawValue)
                .set("head", to: head)
                .set("base", to: base)
        }
    }

    func getPullRequests(
        owner: String,
        repoName: String,
        query: PullRequestQuery? = nil,
        sort: Sorting? = nil,
        pagination: Pagination? = nil
    ) async throws -> [PullRequestResponse] {
        let request = RestRequest<EmptyBody, ListBody<PullRequestResponse>>(
            method: .get,
            path: "/repos/\(owner)/\(repoName)/pulls",
            query: RestQuery
                .merging(query)
                .merging(sort)
                .merging(pagination)
        )
        let response = try await restClient.request(request)
        return response.items
    }
}
