//
//  RepoDetails.swift
//
//
//  Created by v.maltsev on 23.09.2023.
//

public struct RepoDetails {
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

    public func repo() -> Repo {
        Repo(owner: owner, name: name, client: client)
    }
}
