//
//  GoogleOAuthAuthorizer.swift
//
//
//  Created by v.maltsev on 15.08.2023.
//

import Prelude
import RestClient
import Foundation
import os
import AppKit

final class GoogleOAuthAuthorizer {

    struct AuthorizationConfirmation {
        let code: String
        let scopes: [String]
    }

    struct AuthorizationTokensResponse: JSONDecodableBody {
        let accessToken: String
        let expiresIn: TimeInterval
        let refreshToken: String
    }

    static let shared = GoogleOAuthAuthorizer()
    private let logger = Logger(scope: .global)
    private lazy var authClient = buildAuthClient()

    private init() {
    }

    private let clientId: String = "..."
    private let scopes: [String] = [
        "https://www.googleapis.com/auth/drive",
        "https://www.googleapis.com/auth/spreadsheets"
    ]

    private let redirectUri: String = "me.workflows.OAuthHelper:oauth-redirect"

    func authorize() {
        do {
            let url = try confirmationUrl()
            NSWorkspace.shared.open(url)
        } catch {
            logger.fault("Failed to start authorization, \(error, privacy: .public)")
        }
    }

    func processRedirectUrl(_ url: URL) {
        Task {
            do {
                let confirmation = try parseConfirmationUrl(url)
                try await requestRefreshToken(confirmation: confirmation)
            } catch {
                logger.fault("Failed to process redirect url: \(error, privacy: .public)")
            }
        }
    }

    private func confirmationUrl() throws -> URL {
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

    private func parseConfirmationUrl(_ url: URL) throws -> AuthorizationConfirmation {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            throw Failure("Failed to deconstruct redirectUrl")
        }
        
        if let error = components.queryItems?.first(where: { $0.name == "error" })?.value {
            throw Failure("Confirmation failed: \(error)")
        }

        guard let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
            throw Failure("Failed to get code")
        }

        let scopesString = components.queryItems?.first { $0.name == "scope" }?.value ?? ""
        let scopes = scopesString.split(separator: " ").map(String.init)

        return AuthorizationConfirmation(
            code: code,
            scopes: scopes
        )
    }

    private func buildAuthClient() -> RestClient {
        let endpoint = RestEndpoint(host: URL(string: "https://oauth2.googleapis.com/")!)
        let client = RestClient(endpoint: endpoint)
        return client
    }

    private func requestRefreshToken(confirmation: AuthorizationConfirmation) async throws -> AuthorizationTokensResponse {
        let request = RestRequest<UrlEncodedBody, AuthorizationTokensResponse>(
            method: .post,
            path: "/token",
            headers: .set("Content-Type", to: "application/x-www-form-urlencoded"),
            body: UrlEncodedBody(
                query: RestQuery
                    .set("code", to: confirmation.code)
                    .set("client_id", to: clientId)
                    .set("grant_type", to: "authorization_code")
                    .set("redirect_uri", to: redirectUri)
            )
        )

        let response = try await authClient.request(request)
        return response
    }
}
