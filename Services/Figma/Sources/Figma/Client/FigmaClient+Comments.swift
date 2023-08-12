//
//  FigmaClient+Comments.swift
//
//
//  Created by Vladislav Maltsev on 12.08.2023.
//

import Foundation
import RestClient

extension FigmaClient {
    func comments(at fileKey: String) async throws -> CommentsListResponse {
        let request = RestRequest<EmptyBody, CommentsListResponse>(
            method: .get,
            path: "/v1/files/\(fileKey)/comments"
        )

        return try await restClient.request(request)
    }
}
