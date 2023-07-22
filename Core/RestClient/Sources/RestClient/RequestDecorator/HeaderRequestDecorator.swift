//
//  HeaderRequestDecorator.swift
//  Created by Vladislav Maltsev on 22.07.2023.
//

public struct HeadersRequestDecorator: RequestDecorator {
    public var headers: RestHeaders

    public init(headers: RestHeaders) {
        self.headers = headers
    }

    public func request<Request: RestBodyEncodable, Response: RestBodyDecodable>(
        from request: RestRequest<Request, Response>
    ) async throws -> RestRequest<Request, Response> {
        var request = request
        request.headers.merge(headers)
        return request
    }
}
