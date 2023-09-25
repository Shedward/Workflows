//
//  FigmaClient+User.swift
//
//
//  Created by Vladislav Maltsev on 12.08.2023.
//

import RestClient
import Foundation

extension FigmaClient {
    func me() async throws -> UserResponse {
        let request = RestRequest<EmptyBody, UserResponse>(
            method: .get,
            path: "/v1/me"
        )

        return try await restClient.request(request)
    }
}

extension FigmaMock {
    func setMeResponse(response: Result<UserResponse, Error>) async {
        let filter = RestRequestFilter<EmptyBody, UserResponse>(
            method: .exact(.get),
            path: .exact("/v1/me")
        )

        await restClient.addResponse(for: filter, response: response)
    }
}
