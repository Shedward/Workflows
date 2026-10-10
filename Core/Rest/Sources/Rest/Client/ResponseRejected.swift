//
//  ResponseRejected.swift
//  Rest
//

import Core
import Foundation

/// A response the validators refused. Carries the body, so a caller that knows the server's error
/// shape can decode it.
public struct ResponseRejected: DescriptiveError {
    public let statusCode: Int
    public let body: Data
    public let reason: String

    public var userDescription: String {
        "HTTP \(statusCode): \(reason)"
    }

    public init(statusCode: Int, body: Data, reason: String) {
        self.statusCode = statusCode
        self.body = body
        self.reason = reason
    }
}
