//
//  ServerError.swift
//  WorkflowApp
//

import API
import Foundation

/// An error the server explained in its response body.
struct ServerError: LocalizedError {
    let status: Int
    let description: ErrorDescription

    var errorDescription: String? {
        description.userDescription
    }
}
