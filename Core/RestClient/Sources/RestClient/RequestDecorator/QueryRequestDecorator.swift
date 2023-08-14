//
//  QueryRequestDecorator.swift
//
//
//  Created by v.maltsev on 14.08.2023.
//

public struct QueryRequestDecorator: RequestDecorator {
    public var query: RestQuery

    public init(query: RestQuery) {
        self.query = query
    }

    public func request<Request: RestBodyEncodable, Response: RestBodyDecodable>(
        from request: RestRequest<Request, Response>
    ) async throws -> RestRequest<Request, Response> {
        var request = request
        request.query.merge(query)
        return request
    }
}
