//
//  OAuthAuthorizer.swift
//
//
//  Created by v.maltsev on 18.08.2023.
//

import Foundation
import Prelude
import RestClient
import os

/// Authorizer for GoogleCloud
/// Details: https://developers.google.com/identity/protocols/oauth2/native-app
public actor GoogleAuthorizer {

    private let request: AuthorizerRequest
    private let tokensStorage: ThrowingAccessor<Data?>

    private var loadedTokens: AuthorizerTokens?
    private var tokens: AuthorizerTokens {
        get {
            loadTokensIfNeeded()
            return loadedTokens ?? AuthorizerTokens()
        }
        set {
            loadedTokens = newValue
        }
    }

    private let expiringTimeBuffer: TimeInterval = 15

    private lazy var restClient: NetworkRestClient = {
        let endpoint = RestEndpoint(host: URL(string: "https://oauth2.googleapis.com/")!)
        let client = NetworkRestClient(endpoint: endpoint)
        return client
    }()

    public init(request: AuthorizerRequest, tokensStorage: ThrowingAccessor<Data?>) {
        self.request = request
        self.tokensStorage = tokensStorage
    }

    public func authorizationUrl() throws -> URL {
        guard var components = URLComponents(string: "https://accounts.google.com/o/oauth2/v2/auth") else {
            throw Failure("Failed to deconstruct oauth base url")
        }

        components.queryItems = [
            URLQueryItem(name: "scope", value: request.scopes.joined(separator: " ")),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "redirect_uri", value: request.redirectUri),
            URLQueryItem(name: "client_id", value: request.clientId)
        ]

        guard let url = components.url else {
            throw Failure("Failed to construct oauth url")
        }

        return url
    }

    public func processRedirectUrl(_ url: URL) async throws {
        let confirmation = try parseConfirmationUrl(url)
        let refreshTokenResponse = try await requestRefreshToken(confirmation: confirmation)
        let refreshToken = RefreshToken(from: refreshTokenResponse)
        let expiringRefreshToken = Expiring(value: refreshToken, expiresIn: refreshTokenResponse.expiresIn)
        tokens.refreshToken = expiringRefreshToken
        try saveTokens()
        try await reloadAccessTokenIfNeeded()
    }

    public func isAuthorized() -> Bool {
        !(tokens.refreshToken?.isExpired(after: expiringTimeBuffer) ?? true)
    }

    public func authorizedUntil() -> Date? {
        tokens.refreshToken?.expirationTime
    }

    public func logout() throws {
        tokens = .init()
        try tokensStorage.set(nil)
    }

    private func reloadAccessTokenIfNeeded() async throws {
        try loadTokens()
        guard tokens.accessToken?.isExpired(after: expiringTimeBuffer) ?? true else {
            return
        }

        guard let refreshToken = tokens.refreshToken?.after(expiringTimeBuffer) else {
            return
        }

        let response = try await requestAccessToken(refreshToken: refreshToken.token)

        let accessToken = AccessToken(from: response)
        let expiringAccessToken = Expiring(value: accessToken, expiresIn: response.expiresIn)
        tokens.accessToken = expiringAccessToken
        try saveTokens()
    }

    private func parseConfirmationUrl(_ url: URL) throws -> AuthorizerConfirmationCode {
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

        return AuthorizerConfirmationCode(
            code: code,
            scopes: scopes
        )
    }

    private func requestRefreshToken(
        confirmation: AuthorizerConfirmationCode
    ) async throws -> AuthorizationRefreshTokenResponse {
        let request = RestRequest<UrlEncodedBody, AuthorizationRefreshTokenResponse>(
            method: .post,
            path: "/token",
            headers: RestHeaders()
                .set("Content-Type", to: "application/x-www-form-urlencoded"),
            body: UrlEncodedBody(
                query: RestQuery()
                    .set("code", to: confirmation.code)
                    .set("client_id", to: request.clientId)
                    .set("grant_type", to: "authorization_code")
                    .set("redirect_uri", to: request.redirectUri)
            )
        )

        let response = try await restClient.request(request)
        return response
    }

    private func requestAccessToken(
        refreshToken: String
    ) async throws -> AuthorizationAccessTokenResponse {
        let request = RestRequest<UrlEncodedBody, AuthorizationAccessTokenResponse>(
            method: .post,
            path: "/token",
            headers: RestHeaders()
                .set("Content-Type", to: "application/x-www-form-urlencoded"),
            body: UrlEncodedBody(
                query: RestQuery()
                    .set("client_id", to: request.clientId)
                    .set("grant_type", to: "refresh_token")
                    .set("refresh_token", to: refreshToken)
            )
        )

        let response = try await restClient.request(request)
        return response
    }

    private func loadTokensIfNeeded() {
        guard loadedTokens == nil else { return }
        try? loadTokens()
    }

    private func loadTokens() throws {
        let data = try Failure.wrap("Loading GoogleCloud tokens") {
            try tokensStorage.get()
        }

        guard let data else {
            tokens = .init()
            return
        }

        let tokens = try Failure.wrap("Decoding GoogleCloud tokens") {
            try JSONDecoder().decode(AuthorizerTokens.self, from: data)
        }
        self.tokens = tokens
    }

    private func saveTokens() throws {
        let data = try Failure.wrap("Encoding GoogleCloud tokens") {
            try JSONEncoder().encode(tokens)
        }
        try Failure.wrap("Saving GoogleCloud") {
            try tokensStorage.set(data)
        }
    }
}

extension GoogleAuthorizer: AccessTokenAuthorizer {
    public func accessToken() async throws -> String {
        try await reloadAccessTokenIfNeeded()

        if let accessToken = tokens.accessToken?.after(expiringTimeBuffer) {
            return accessToken.token
        }

        throw AuthorizerError.signInRequired
    }
}
