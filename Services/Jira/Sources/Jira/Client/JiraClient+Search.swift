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
                .merging(with: pagination.asRestQuery())
                .merging(with: fieldsQueryParameter(Fields.fieldKeys))
        )

        let response = try await restClient.request(request)
        return response.items
    }

    private func fieldsQueryParameter(_ fields: [IssueFieldKey]) -> RestQuery {
        guard !fields.isEmpty else { return RestQuery() }

        let fieldNames = fields.map(\.rawValue).joined(separator: ",")
        return .set("fields", to: fieldNames)
    }
}
