//
//  Sorting.swift
//  Created by Vladislav Maltsev on 22.07.2023.
//

import RestClient

public enum SortingDirection: String {
    case ascending = "asc"
    case descending = "desc"
}

public struct Sorting<SortingKey> {
    public var sortBy: SortingKey
    public var direction: SortingDirection

    public init(sortBy: SortingKey, direction: SortingDirection = .ascending) {
        self.sortBy = sortBy
        self.direction = direction
    }
}

extension Sorting where SortingKey: RawRepresentable, SortingKey.RawValue == String {
    func asRestQuery() -> RestQuery {
        return RestQuery
            .set("sort", to: sortBy.rawValue)
            .set("direction", to: direction.rawValue)
    }
}
