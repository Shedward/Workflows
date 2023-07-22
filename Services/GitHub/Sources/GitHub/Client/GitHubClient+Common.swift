//
//  GitHubClient+Common.swift
//  Created by Vladislav Maltsev on 22.07.2023.
//

import RestClient

extension GitHubClient {

    struct Pagination: RestQueryConvertible {
        var page: Int
        var perPage: Int?

        func asRestQuery() -> RestQuery {
            RestQuery
                .set("per_page", to: perPage)
                .set("page", to: page)
        }
    }

    struct Sorting: RestQueryConvertible {
        enum Direction: String {
            case ascending = "asc"
            case descending = "desc"
        }

        var sortBy: String
        var direction: Direction = .ascending

        func asRestQuery() -> RestQuery {
            RestQuery
                .set("sort", to: sortBy)
                .set("direction", to: direction.rawValue)
        }
    }
}
