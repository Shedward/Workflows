//
//  FigmaClient+Comments.swift
//
//
//  Created by Vladislav Maltsev on 12.08.2023.
//

import Foundation
import RestClient

extension FigmaClient {
    func comments(fileKey: String) async throws -> CommentsListResponse {
        let request = RestRequest<EmptyBody, CommentsListResponse>(
            method: .get,
            path: "/v1/files/\(fileKey)/comments"
        )

        return try await restClient.request(request)
    }
}

extension FigmaMock {
    func setCommentsResponse(
        fileKey: String,
        response: Result<CommentsListResponse, Error>
    ) async {
        let filter = RestRequestFilter<EmptyBody, CommentsListResponse>(
            method: .exact(.get),
            path: .exact("/v1/files/\(fileKey)/comments")
        )

        await restClient.addResponse(for: filter, response: response)
    }
}
