//
//  RestRequestFilter.swift
//
//
//  Created by v.maltsev on 23.09.2023.
//

import Prelude

public struct RestRequestFilter<RequestBody: RestBodyEncodable, ResponseBody: RestBodyDecodable> {
    let method: ValueFilter<RestMethod>
    let path: ValueFilter<String?>
    let query: ValueFilter<RestQuery>
    let headers: ValueFilter<RestHeaders>
    let body: ValueFilter<RequestBody>

    public init(
        method: ValueFilter<RestMethod> = .any(),
        path: ValueFilter<String?> = .any(),
        query: ValueFilter<RestQuery> = .any(),
        headers: ValueFilter<RestHeaders> = .any(),
        body: ValueFilter<RequestBody> = .any()
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
