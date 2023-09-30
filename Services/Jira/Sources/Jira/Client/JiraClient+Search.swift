//
//  JiraClient+Search.swift
//  Created by Vladislav Maltsev on 27.07.2023.
//

import RestClient
import Prelude

extension JiraClient {

    func getSearchResults<Fields: IssueFields>(
        query: JQLQuery,
        pagination: Pagination,
        fields: Fields.Type
    ) async throws -> [IssueDetails<Fields>] {
        let request = RestRequest<EmptyBody, PageResponse<IssueDetails<Fields>, IssuesPageDynamicKeys>>(
            method: .get,
            path: "/search",
            query: RestQuery()
                .set("jql", to: query.rawValue)
                .set("fields", to: Fields.fieldsDescription)
                .merging(with: pagination.asRestQuery())
        )

        let response = try await restClient.request(request)
        return response.items
    }
}

extension JiraMock {
    
    func addGetSearchResultsResponse<Fields: IssueFields>(
        query: JQLQuery,
        fields: Fields.Type,
        pagination: Pagination,
        response: Result<[IssueDetails<Fields>], Error>
    ) async {
        let filter = RestRequestFilter<EmptyBody, PageResponse<IssueDetails<Fields>, IssuesPageDynamicKeys>>(
            method: .exact(.get),
            path: .exact("/search"),
            query: .exact(
                RestQuery()
                    .set("jql", to: query.rawValue)
                    .set("fields", to: Fields.fieldsDescription)
                    .merging(with: pagination.asRestQuery())
            )
        )
        
        await restClient.addHandler(for: filter) { request in
            let successResponse = try response.get()
            let pagination = try? Pagination(restQuery: request.query)
            let currentPage = pagination?.page ?? 0
            
            return PageResponse(
                startAt: currentPage,
                maxResults: pagination?.pageSize ?? .max,
                total: successResponse.count,
                items: currentPage == 0 ? successResponse : []
            )
        }
    }
    
    func addGetSearchResultsResponse<Fields: IssueFields>(
        query: JQLQuery,
        fields: Fields.Type,
        pageSize: Int,
        response: Result<[IssueDetails<Fields>], Error>
    ) async {
        switch response {
        case .success(let success):
            for page in success.chunked(into: pageSize) {
                await addGetSearchResultsResponse(
                    query: query,
                    fields: fields,
                    pagination: Pagination(page: 0, pageSize: pageSize),
                    response: .success(page)
                )
            }
        case .failure(let failure):
            await addGetSearchResultsResponse(
                query: query,
                fields: fields,
                pagination: Pagination(page: 0, pageSize: pageSize),
                response: .failure(failure)
            )
        }
    }
}
