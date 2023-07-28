//
//  JiraClient+Search.swift
//  Created by Vladislav Maltsev on 27.07.2023.
//

import RestClient

extension JiraClient {

    func getSearchResults(query: JQLQuery, pagination: Pagination) async throws -> [IssueResponse] {
        let request = RestRequest<EmptyBody, PageResponse<IssueResponse, IssuesPageDynamicKeys>>(
            method: .get,
            path: "/search",
            query: RestQuery
                .set("jql", to: query.rawValue)
                .merging(with: pagination.asRestQuery())
        )

        let response = try await restClient.request(request)
        return response.items
    }
}
