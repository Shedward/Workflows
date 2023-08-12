//
//  User.swift
//
//
//  Created by Vladislav Maltsev on 12.08.2023.
//

public struct User {
    private let client: FigmaClient

    public let id: String
    public let email: String
    public let handle: String

    init(response: UserResponse, client: FigmaClient) {
        self.client = client
        self.id = response.id
        self.email = response.email
        self.handle = response.handle
    }
}
