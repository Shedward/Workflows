//
//  Pagination.swift
//  Created by Vladislav Maltsev on 22.07.2023.
//

import Foundation
import RestClient

public struct Pagination {
    public var page: Int
    public var perPage: Int?

    public init(page: Int, perPage: Int? = nil) {
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
}
