//
//  DescriptiveError.swift
//  Core
//
//  Created by Vlad Maltsev on 21.12.2025.
//

import Foundation

/// Who has to act on an error. The server maps each kind to an HTTP status.
public enum ErrorKind: Sendable {
    /// The request itself is wrong: the caller fixes it.
    case invalidRequest
    /// The request addresses something that does not exist: the caller checks the id.
    case notFound
    /// The target exists but its current state does not allow this: the caller re-reads the state.
    case conflict
    /// Our side failed: nothing the caller can do.
    case `internal`
}

public protocol DescriptiveError: Error, LocalizedError {
    var userDescription: String { get }
    var kind: ErrorKind { get }
}

public extension DescriptiveError {
    var userDescription: String {
        "\(self)"
    }

    var kind: ErrorKind {
        .internal
    }

    var errorDescription: String? {
        userDescription
    }
}
