//
//  URLEncodedBody.swift
//  Rest
//
//  Created by Vlad Maltsev on 21.12.2025.
//

import Foundation

public struct UrlEncodedBody: DataEncodable {
    public var query: Query

    public var contentType: String? { "application/x-www-form-urlencoded" }

    public init(query: Query) {
        self.query = query
    }

    public func data() -> Data? {
        let string = query.values
            .compactMap { key, value in
                guard
                    let queryValue = value.queryValue,
                    let encodedValue = queryValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                else { return nil }

                return "\(key)=\(encodedValue)"
            }
            .joined(separator: "&")
        return string.data(using: .utf8)
    }
}
