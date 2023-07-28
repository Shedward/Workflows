//
//  Pagination.swift
//  Created by Vladislav Maltsev on 22.07.2023.
//

import Foundation
import RestClient

struct Pagination {
    var page: Int
    var perPage: Int?
}

extension Pagination {
    func asRestQuery() -> RestQuery {
        .set("per_page", to: perPage)
        .set("page", to: page)
    }
}
