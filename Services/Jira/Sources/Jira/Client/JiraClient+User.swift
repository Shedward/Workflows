//
//  JiraClient+User.swift
//  Created by Vladislav Maltsev on 26.07.2023.
//

import RestClient

extension JiraClient {

    func getCurrentUser() async throws -> UserResponse {
        let request = RestRequest<EmptyBody, UserResponse>(
            method: .get,
            path: "/myself"
        )
        return try await restClient.request(request)
    }

    func getUser(username: String) async throws -> UserResponse {
        let request = getUserRequest(query: RestQuery.set("username", to: username))
        return try await restClient.request(request)
    }

    func getUser(key: String) async throws -> UserResponse {
        let request = getUserRequest(query: RestQuery.set("key", to: key))
        return try await restClient.request(request)
    }

    private func getUserRequest(query: RestQuery) -> RestRequest<EmptyBody, UserResponse> {
        .init(
            method: .get,
            path: "/user",
            query: query
        )
    }
}
