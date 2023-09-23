//
//  Pagination.swift
//  Created by Vladislav Maltsev on 22.07.2023.
//

import Foundation
import Prelude
import RestClient

struct Pagination {
    var page: Int
    var perPage: Int?

    init(page: Int, perPage: Int? = nil) {
        self.page = page
        self.perPage = perPage
    }
}

extension Pagination {
    func asRestQuery() -> RestQuery {
        RestQuery
            .set("per_page", to: perPage)
            .set("page", to: page)
    }

    init?(restQuery: RestQuery) throws {
        guard let pageString = restQuery.values["page"] else {
            throw Failure("Not found required `page` in RestQuery")
        }

        guard let page = Int(pageString) else {
            throw Failure("`page` is not a number in Rest Query")
        }

        self.page = page

        if let perPageString = restQuery.values["per_page"] {
            guard let perPage = Int(perPageString) else {
                throw Failure("`per_page` is not a number in Rest Query")
            }

            self.perPage = perPage
        }
    }
}
