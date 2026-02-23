//
//  Failure+HTTPResponseError.swift
//  WorkflowServer
//
//  Created by Vlad Maltsev on 22.02.2026.
//

import Core
import Hummingbird

extension Failure: @retroactive ResponseGenerator {
    public func response(from request: Request, context: some RequestContext) throws -> Response {
        try ErrorResponse(
            status: status,
            userDescription: userDescription,
            debugDescription: debugDescription
        ).response(from: request, context: context)
    }
}

extension Failure: @retroactive HTTPResponseError {
    public var status: HTTPResponse.Status {
        .internalServerError
    }
}
