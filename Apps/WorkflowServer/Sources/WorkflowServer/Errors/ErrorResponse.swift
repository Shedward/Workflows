//
//  ErrorResponse.swift
//  WorkflowServer
//
//  Created by Vlad Maltsev on 23.02.2026.
//

import Foundation
import Hummingbird

struct ErrorResponse: ResponseGenerator {
    let status: HTTPResponse.Status
    let userDescription: String
    let debugDescription: String?

    init(
        status: HTTPResponse.Status = .internalServerError,
        userDescription: String,
        debugDescription: String? = nil
    ) {
        self.status = status
        self.userDescription = userDescription
        self.debugDescription = debugDescription
    }

    func response(from request: Request, context: some RequestContext) throws -> Response {
        let body =  Body(userDescription: userDescription, debugDescription: debugDescription)
        var response = try context.responseEncoder.encode(body, from: request, context: context)
        response.status = status
        return response
    }
}

extension ErrorResponse {
    struct Body: ResponseCodable {
        let userDescription: String
        let debugDescription: String?
    }
}
