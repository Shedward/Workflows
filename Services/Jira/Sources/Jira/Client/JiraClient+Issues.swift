//
//  JiraClient+Issues.swift
//  Created by Vladislav Maltsev on 26.07.2023.
//

import Prelude
import RestClient

extension JiraClient {

    func getIssue<Fields: IssueFields>(key: String, fields: Fields.Type) async throws -> IssueResponse<Fields> {
        let request = RestRequest<EmptyBody, IssueResponse<Fields>>(
            method: .get,
            path: "issue/\(key)",
            query: RestQuery
                .set("fields", to: Fields.fieldsDescription)
        )
        return try await restClient.request(request)
    }
}
