//
//  AuthorizerError.swift
//
//
//  Created by v.maltsev on 23.08.2023.
//

import Prelude

public enum AuthorizerError: Error {
    case signInRequired
}

extension AuthorizerError: DescriptiveError {
    public var userDescription: String {
        switch self {
        case .signInRequired:
            return "Google sign in required"
        }
    }
}
