//
//  PullRequest.swift
//  Created by Vladislav Maltsev on 22.07.2023.
//

public struct PullRequest {
    private let client: GitHubClient

    public let id: Int
    public let title: String

    init(response: PullRequestResponse, client: GitHubClient) {
        self.id = response.id
        self.title = response.title
        self.client = client
    }
}
