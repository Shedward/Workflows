//
//  GitHubClient+User.swift
//  Created by Vladislav Maltsev on 22.07.2023.
//

import RestClient

extension GitHubClient {

    func getCurrentUser() async throws -> UserResponse {
        let request = RestRequest<EmptyBody, UserResponse>(
            method: .get,
            path: "/user"
        )
        return try await restClient.request(request)
    }
}