//
//  ValueMockRequestHandler.swift
//
//
//  Created by v.maltsev on 23.09.2023.
//

public struct ValueMockRequestHanlder<RequestBody, ResponseBody>: MockRequestHandler
    where RequestBody: RestBodyEncodable, ResponseBody: RestBodyDecodable {

    private let requestFilter: RestRequestFilter<RequestBody, ResponseBody>
    private let response: ResponseBody

    init(
        requestFilter: RestRequestFilter<RequestBody, ResponseBody> = .any(),
        response: ResponseBody
    ) {
        self.requestFilter = requestFilter
        self.response = response
    }

    public func shouldAcceptRequest(_ request: RestRequest<RequestBody, ResponseBody>) -> Bool {
        requestFilter.matching(request)
    }

    public func response(for request: RestRequest<RequestBody, ResponseBody>) throws -> ResponseBody {
        response
    }
}

extension MockRestClient {
    public func addResponse<RequestBody, ResponseBody>(
        for requestFilter: RestRequestFilter<RequestBody, ResponseBody> = .any(),
        response: ResponseBody
    ) where RequestBody: RestBodyEncodable, RequestBody: RestBodyDecodable {
        let handler = ValueMockRequestHanlder(requestFilter: requestFilter, response: response)
        addHandler(AnyMockRequestHandler(handler))
    }
}
