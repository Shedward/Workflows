//
//  User.swift
//  Created by Vladislav Maltsev on 26.07.2023.
//

public struct User {
    public let name: String
    public let key: String

    private let client: JiraClient

    init(response: UserResponse, client: JiraClient) {
        self.name = response.name
        self.key = response.key

        self.client = client
    }
}
