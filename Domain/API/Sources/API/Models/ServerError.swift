//
//  ServerError.swift
//  API
//

import Core

public struct ServerError: DescriptiveError {
    public let status: Int
    public let description: ErrorDescription

    public var userDescription: String {
        description.userDescription
    }
}
