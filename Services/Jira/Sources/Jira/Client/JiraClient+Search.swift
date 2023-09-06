//
//  JiraClient+Search.swift
//  Created by Vladislav Maltsev on 27.07.2023.
//

import RestClient

extension JiraClient {

    func getSearchResults<Fields: IssueFields>(
        query: JQLQuery,
        pagination: Pagination,
        fields: Fields.Type
    ) async throws -> [IssueResponse<Fields>] {
        let request = RestRequest<EmptyBody, PageResponse<IssueResponse<Fields>, IssuesPageDynamicKeys>>(
            method: .get,
            path: "/search",
            query: RestQuery
                .set("jql", to: query.rawValue)
                .set("fields", to: Fields.fieldsDescription)
                .merging(with: pagination.asRestQuery())
        )

        let response = try await restClient.request(request)
        return response.items
    }
}
