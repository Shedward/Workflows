//
//  RestQueryConvertible.swift
//  Created by Vladislav Maltsev on 22.07.2023.
//

public protocol RestQueryConvertible {
    func asRestQuery() -> RestQuery
}

extension RestQuery {
    public static  func merging( _ queryConvertible: RestQueryConvertible?) -> Self {
        guard let queryConvertible else { return Self() }
        return queryConvertible.asRestQuery()
    }

    public func merging(_ queryConvertible: RestQueryConvertible?) -> Self {
        guard let queryConvertible else { return self }
        return merging(with: queryConvertible.asRestQuery())
    }
}
