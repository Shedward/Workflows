//
//  Jira.swift
//  Created by Vladislav Maltsev on 26.07.2023.
//

import Foundation

public struct Jira {
    private let client: JiraClient

    public init(serverHost: URL, credentials: JiraServerCredentials) throws {
        client = try JiraClient.jiraServerClient(host: serverHost, credentials: credentials)
    }

    public func currentUser() async throws -> User {
        let response = try await client.getCurrentUser()
        return User(response: response, client: client)
    }

    public func user(name: String) async throws -> User {
        let response = try await client.getUser(username: name)
        return User(response: response, client: client)
    }
}
