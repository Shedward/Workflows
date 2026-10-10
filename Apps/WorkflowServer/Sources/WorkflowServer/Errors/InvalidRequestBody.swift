//
//  InvalidRequestBody.swift
//  WorkflowServer
//

import Core

/// The request body could not be decoded into what the endpoint expects.
struct InvalidRequestBody: DescriptiveError {
    let expected: String
    let underlying: any Error

    var userDescription: String {
        "Request body is not a valid \(expected): \(underlying)"
    }
}
