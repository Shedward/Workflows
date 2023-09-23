//
//  GitHubClient+Repo.swift
//  Created by Vladislav Maltsev on 22.07.2023.
//

import RestClient

extension GitHubClient {

    func getRepo(owner: String, name: String) async throws -> RepoResponse {
        let request = RestRequest<EmptyBody, RepoResponse>(
            method: .get,
            path: "/repos/\(owner)/\(name)"
        )
        return try await restClient.request(request)
    }
}

extension GitHubMock {

    func setRepo(owner: String, name: String, repo: RepoResponse) async {
        await mockRestClient.addResponse(
            for: RestRequestFilter<EmptyBody, RepoResponse>(
                method: .exact(.get),
                path: .exact("/repos/\(owner)/\(name)")
            ),
            response: repo
        )
    }
}
