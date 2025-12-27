//
//  AddQueryRequestDecorator.swift
//  RestClient
//
//  Created by Vlad Maltsev on 21.12.2025.
//

public struct AddQueryRequestDecorator: RequestDecorator {
    private let additionalQuery: Query

    public init(_ additionalQuery: Query) {
        self.additionalQuery = additionalQuery
    }
    
    public func decorate<RequestBody, ResponseBody>(
        _ request: Request<RequestBody, ResponseBody>
    ) async throws -> Request<RequestBody, ResponseBody> {
        request.with { $0.query.merge(additionalQuery) }
    }
}

extension RequestDecoratorsSet {
    public func addQuery(_ additionalQuery: Query) -> Self {
        appending(AddQueryRequestDecorator(additionalQuery))
    }
}
