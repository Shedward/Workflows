//
//  GitHub.swift
//  Created by Vladislav Maltsev on 22.07.2023.
//

public struct GitHub {
    private let client: GitHubClient

    public init(token: String) {
        self.client = GitHubClient(token: token)
    }

    public func currentUser() async throws -> User {
        let userResponse = try await client.currentUser()
        return User(userResponse: userResponse, client: client)
    }

    public func repo(owner: String, name: String) async throws -> Repo {
        let repoResponse = try await client.getRepo(owner: owner, name: name)
        return Repo(response: repoResponse, client: client)
    }
}
