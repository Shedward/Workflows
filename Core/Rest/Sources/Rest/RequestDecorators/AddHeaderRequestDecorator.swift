//
//  AddHeaderRequestDecorator.swift
//  Rest
//
//  Created by Vlad Maltsev on 21.12.2025.
//

public struct AddHeadersRequestDecorator: RequestDecorator {
    private let additionalHeaders: Headers

    public init(_ additionalHeaders: Headers) {
        self.additionalHeaders = additionalHeaders
    }

    public func decorate<RequestBody, ResponseBody>(
        _ request: Request<RequestBody, ResponseBody>
    ) async throws -> Request<RequestBody, ResponseBody> {
        request.with { $0.headers.merge(additionalHeaders) }
    }
}

extension RequestDecoratorsSet {
    public func addHeaders(_ additionalHeaders: Headers) -> Self {
        appending(AddHeadersRequestDecorator(additionalHeaders))
    }
}
