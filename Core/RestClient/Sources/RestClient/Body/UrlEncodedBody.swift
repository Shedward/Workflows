//
//  UrlEncodedBody.swift
//
//
//  Created by v.maltsev on 15.08.2023.
//

import Foundation

public struct UrlEncodedBody: RestBodyEncodable {
    public var query: RestQuery

    public init(query: RestQuery) {
        self.query = query
    }

    public func data() throws -> Data? {
        let string = query.values
            .map { key, value in
                let encodedValue = value
                    .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                    ?? value
                return "\(key)=\(encodedValue)"
            }
            .joined(separator: "&")
        let data = string.data(using: .utf8)
        return data
    }
}
