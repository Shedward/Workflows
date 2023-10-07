//
//  RestRequestFilter.swift
//
//
//  Created by v.maltsev on 23.09.2023.
//

import Prelude

public struct RestRequestFilter<RequestBody: RestBodyEncodable, ResponseBody: RestBodyDecodable> {
    let method: Filter<RestMethod>
    let path: Filter<String?>
    let query: Filter<RestQuery>
    let headers: Filter<RestHeaders>
    let body: Filter<RequestBody>

    public init(
        method: Filter<RestMethod> = .any(),
        path: Filter<String?> = .any(),
        query: Filter<RestQuery> = .any(),
        headers: Filter<RestHeaders> = .any(),
        body: Filter<RequestBody> = .any()
    ) {
        self.method = method
        self.path = path
        self.query = query
        self.headers = headers
        self.body = body
    }

    public func matching(_ request: RestRequest<RequestBody, ResponseBody>) -> Bool {
        method.matching(request.method)
            && path.matching(request.path)
            && query.matching(request.query)
            && headers.matching(request.headers)
            && body.matching(request.body)
    }
}

extension RestRequestFilter {
    public static func any() -> Self {
        .init()
    }
}
