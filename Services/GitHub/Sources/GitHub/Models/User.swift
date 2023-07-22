//
//  User.swift
//  Created by Vladislav Maltsev on 22.07.2023.
//

public struct User {
    public let id: Int
    public let login: String
    public let name: String

    private let client: GitHubClient

    init(userResponse: UserResponse, client: GitHubClient) {
        self.client = client
        self.id = userResponse.id
        self.login = userResponse.login
        self.name = userResponse.name
    }
}
