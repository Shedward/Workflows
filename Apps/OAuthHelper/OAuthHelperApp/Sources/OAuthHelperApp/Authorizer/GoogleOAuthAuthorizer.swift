//
//  GoogleOAuthAuthorizer.swift
//
//
//  Created by v.maltsev on 15.08.2023.
//

import Prelude
import Foundation

final class GoogleOAuthAuthorizationUrl {
    private let clientId: String = "546377572292-380otnito02mdjd4vhacgheri475f482.apps.googleusercontent.com"
    private let scopes: [String] = [
        "https://www.googleapis.com/auth/drive",
        "https://www.googleapis.com/auth/spreadsheets"
    ]

    private let redirectUri: String = "me.workflows.OAuthHelper:oauth-redirect"

    func buildUrl() throws -> URL {
        guard var components = URLComponents(string: "https://accounts.google.com/o/oauth2/v2/auth") else {
            throw Failure("Failed to deconstruct oauth base url")
        }

        components.queryItems = [
            URLQueryItem(name: "scope", value: scopes.joined(separator: " ")),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "redirect_uri", value: redirectUri),
            URLQueryItem(name: "client_id", value: clientId)
        ]

        guard let url = components.url else {
            throw Failure("Failed to construct oauth url")
        }

        return url
    }
}
