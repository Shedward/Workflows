//
//  Repo.swift
//  Created by Vladislav Maltsev on 22.07.2023.
//

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
}
