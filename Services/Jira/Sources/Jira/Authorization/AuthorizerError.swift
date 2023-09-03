//
//  AuthorizerError.swift
//
//
//  Created by v.maltsev on 03.09.2023.
//

import Prelude

public enum AuthorizerError: Error {
    case signInRequired
}

extension AuthorizerError: DescriptiveError {
    public var userDescription: String {
        switch self {
        case .signInRequired:
            return "Jira sign in required"
        }
    }
}
