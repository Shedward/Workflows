//
//  GitHub.swift
//  Created by Vladislav Maltsev on 22.07.2023.
//

public struct GitHub {
    private let client: GitHubClient

    public init(token: String) {
        self.client = GitHubClient(token: token)
    }

    init(mock: GitHubMock) {
        self.client = GitHubClient(mock: mock)
    }

    public func currentUser() async throws -> User {
        let userResponse = try await client.getCurrentUser()
        return User(userResponse: userResponse, client: client)
    }

    public func repo(owner: String, name: String) -> Repo {
        Repo(owner: owner, name: name, client: client)
    }
}
