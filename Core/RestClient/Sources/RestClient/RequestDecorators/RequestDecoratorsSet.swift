//
//  RequestModifiersSet.swift
//  RestClient
//
//  Created by Vlad Maltsev on 21.12.2025.
//

import Core

public struct RequestDecoratorsSet: RequestDecorator {

    public var items: [RequestDecorator]

    public init() {
        self.items = []
    }

    public func decorate<RequestBody, ResponseBody>(
        _ request: Request<RequestBody, ResponseBody>
    ) async throws -> Request<RequestBody, ResponseBody> {

        var request = request
        for item in items {
            request = try await item.decorate(request)
        }

        return request
    }
}

extension RequestDecoratorsSet: Defaultable { }
extension RequestDecoratorsSet: ArraySemantic { }
extension RequestDecoratorsSet: Modifiers { }
