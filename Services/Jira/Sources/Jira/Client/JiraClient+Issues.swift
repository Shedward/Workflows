//
//  JiraClient+Issues.swift
//  Created by Vladislav Maltsev on 26.07.2023.
//

import Prelude
import RestClient

extension JiraClient {

    func getIssue(key: String) async throws -> IssueResponse<CodableVoid> {
        let request = RestRequest<EmptyBody, IssueResponse<CodableVoid>>(
            method: .get,
            path: "issue/\(key)"
        )
        return try await restClient.request(request)
    }
}
