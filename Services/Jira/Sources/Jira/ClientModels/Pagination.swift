//
//  Pagination.swift
//  Created by Vladislav Maltsev on 27.07.2023.
//

import RestClient

struct Pagination {
    var page: Int
    var pageSize: Int
}

extension Pagination {
    func asRestQuery() -> RestQuery {
        RestQuery()
            .set("startAt", to: pageSize * page)
            .set("maxResults", to: pageSize)
    }
}
