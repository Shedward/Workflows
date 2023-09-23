//
//  RestRequestFilter.swift
//
//
//  Created by v.maltsev on 23.09.2023.
//

import Prelude

public struct RestRequestFilter<Request: RestBodyEncodable, Response: RestBodyDecodable> {
    let method: ValueFilter<RestMethod>
    let path: ValueFilter<String?>
    let query: ValueFilter<RestQuery>
    let headers: ValueFilter<RestHeaders>

    public init(
        method: ValueFilter<RestMethod> = .any(),
        path: ValueFilter<String?> = .any(),
        query: ValueFilter<RestQuery> = .any(),
        headers: ValueFilter<RestHeaders> = .any()
    ) {
        self.method = method
        self.path = path
        self.query = query
        self.headers = headers
    }

    public func matching(_ request: RestRequest<Request, Response>) -> Bool {
        method.matching(request.method)
            && path.matching(request.path)
            && query.matching(request.query)
            && headers.matching(request.headers)
    }
}

extension RestRequestFilter {
    public static func any() -> Self {
        .init()
    }
}
