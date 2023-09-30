//
//  Pagination.swift
//  Created by Vladislav Maltsev on 27.07.2023.
//

import Prelude
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
    
    init(restQuery: RestQuery) throws {
        guard let startAtString = restQuery.values["startAt"] else {
            throw Failure("Not found required `startAt` in RestQuery")
        }
        
        guard let startAt = Int(startAtString) else {
            throw Failure("`startAt` is not a number in RestQuery")
        }
        
        self.page = startAt
        
        guard let maxResultsString = restQuery.values["maxResults"] else {
            throw Failure("`maxResults` is ")
        }
        
        guard let maxResults = Int(maxResultsString) else {
            throw Failure("`maxResults` is not a number in RestQuery")
        }
        self.pageSize = maxResults
    }
}
