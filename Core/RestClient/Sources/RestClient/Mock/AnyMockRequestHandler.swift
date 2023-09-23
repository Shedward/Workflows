//
//  AnyMockRequestHandler.swift
//  
//
//  Created by v.maltsev on 23.09.2023.
//

public protocol ErasedAnyMockRequestHandler {
}

public struct AnyMockRequestHandler<RequestBody, ResponseBody>: MockRequestHandler, ErasedAnyMockRequestHandler
    where RequestBody: RestBodyEncodable, ResponseBody: RestBodyDecodable {

    private let shouldAcceptRequestAction: (RestRequest<RequestBody, ResponseBody>) -> Bool
    private let responseForRequestAction: (RestRequest<RequestBody, ResponseBody>) throws -> ResponseBody

    public init<Wrapped: MockRequestHandler>(
        _ wrapped: Wrapped
    ) where Wrapped.RequestBody == RequestBody, Wrapped.ResponseBody == ResponseBody {
        shouldAcceptRequestAction = wrapped.shouldAcceptRequest
        responseForRequestAction = wrapped.response
    }

    public func shouldAcceptRequest(_ request: RestRequest<RequestBody, ResponseBody>) -> Bool {
        shouldAcceptRequestAction(request)
    }

    public func response(for request: RestRequest<RequestBody, ResponseBody>) throws -> ResponseBody {
        try responseForRequestAction(request)
    }
}
