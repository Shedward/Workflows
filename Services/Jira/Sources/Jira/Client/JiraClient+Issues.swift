//
//  JiraClient+Issues.swift
//  Created by Vladislav Maltsev on 26.07.2023.
//

import RestClient

extension JiraClient {

    func getIssue(key: String) async throws -> IssueResponse {
        let request = RestRequest<EmptyBody, IssueResponse>(
            method: .get,
            path: "issue/\(key)"
        )
        return try await restClient.request(request)
    }
}
