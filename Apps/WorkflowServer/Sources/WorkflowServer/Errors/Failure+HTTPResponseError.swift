//
//  Failure+HTTPResponseError.swift
//  WorkflowServer
//
//  Created by Vlad Maltsev on 22.02.2026.
//

import Core
import Hummingbird

extension Failure: @retroactive HTTPResponseError, APIError {
    public var status: HTTPResponse.Status {
        .internalServerError
    }
}
