//
//  BlockMockRequestHanlder.swift
//
//
//  Created by v.maltsev on 23.09.2023.
//

public struct BlockMockRequestHanlder<RequestBody, ResponseBody>: MockRequestHandler
    where RequestBody: RestBodyEncodable, ResponseBody: RestBodyDecodable {

    private let requestFilter: RestRequestFilter<RequestBody, ResponseBody>
    private let responseBuilder: (RestRequest<RequestBody, ResponseBody>) throws -> ResponseBody

    init(
        requestFilter: RestRequestFilter<RequestBody, ResponseBody> = .any(),
        responseBuilder: @escaping (RestRequest<RequestBody, ResponseBody>) throws -> ResponseBody
    ) {
        self.requestFilter = requestFilter
        self.responseBuilder = responseBuilder
    }

    public func shouldAcceptRequest(_ request: RestRequest<RequestBody, ResponseBody>) -> Bool {
        requestFilter.matching(request)
    }

    public func response(for request: RestRequest<RequestBody, ResponseBody>) throws -> ResponseBody {
        try responseBuilder(request)
    }
}

extension MockRestClient {
    public func addHandler<RequestBody, ResponseBody>(
        for requestFilter: RestRequestFilter<RequestBody, ResponseBody> = .any(),
        responseBuilder: @escaping (RestRequest<RequestBody, ResponseBody>) throws -> ResponseBody
    ) where RequestBody: RestBodyEncodable, RequestBody: RestBodyDecodable {
        let handler = BlockMockRequestHanlder(requestFilter: requestFilter, responseBuilder: responseBuilder)
        addHandler(AnyMockRequestHandler(handler))
    }
}
