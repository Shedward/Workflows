//
//  UserOAuthTokenProvider.swift
//  GoogleServices
//

import Core
import CryptoKit
import Foundation
import Rest
import Security

/// Google OAuth2 token provider using the user's own credentials (3-legged OAuth).
///
/// - On first use (no stored refresh token): `authorizationHeaders()` throws a
///   descriptive error telling the caller to visit `/auth/google` to authorize.
/// - On subsequent uses: reads the refresh token from Keychain, exchanges it for
///   an access token, and caches it in memory until it expires.
///
/// Implements `OAuthProvider` so the server can expose `/auth/google` endpoints
/// that let any client (browser, CLI, desktop app) trigger the authorization flow.
public actor UserOAuthTokenProvider: AccessTokenAuthorizer, OAuthProvider {

    // MARK: - OAuthProvider identity

    public nonisolated let serviceID = "google"
    public nonisolated let displayName = "Google"

    // MARK: - Configuration

    private let credentials: GoogleOAuthCredentials
    private let scopes: [String]
    private let keychain = KeychainStorage(service: "com.workflows.google")
    private static let refreshTokenKey = "refreshToken"

    // MARK: - Cached access token

    private var cachedAccessToken: String?
    private var accessTokenExpiresAt: Date = .distantPast

    // MARK: - Pending PKCE verifiers (keyed by state UUID string)

    private struct PendingVerifier {
        let codeVerifier: String
        let createdAt: Date
    }
    private var pendingVerifiers: [String: PendingVerifier] = [:]
    private static let verifierTTL: TimeInterval = 600 // 10 minutes

    private let redirectURI: String

    // MARK: - Init

    public init(credentials: GoogleOAuthCredentials, scopes: [String], redirectURI: String) {
        self.credentials = credentials
        self.scopes = scopes
        self.redirectURI = redirectURI
    }

    // MARK: - AccessTokenAuthorizer

    public func authorizationHeaders() async throws -> Headers {
        let token = try await validAccessToken()
        return bearer(token)
    }

    // MARK: - OAuthProvider

    public func isAuthorized() async -> Bool {
        (try? keychain.read(key: Self.refreshTokenKey)) != nil
    }

    public func authorizationURL() async throws -> URL {
        pruneExpiredVerifiers()

        let (verifier, challenge) = makePKCE()
        let state = UUID().uuidString
        pendingVerifiers[state] = PendingVerifier(codeVerifier: verifier, createdAt: Date())

        return try buildAuthURL(codeChallenge: challenge, state: state)
    }

    public func handleCallback(code: String, state: String) async throws {
        pruneExpiredVerifiers()

        guard let pending = pendingVerifiers.removeValue(forKey: state) else {
            throw Failure("OAuth callback has invalid or expired state parameter")
        }
        guard Date().timeIntervalSince(pending.createdAt) < Self.verifierTTL else {
            throw Failure("OAuth authorization request has expired, please try again")
        }

        let response = try await exchangeCodeForTokens(code: code, codeVerifier: pending.codeVerifier)

        if let refreshToken = response.refresh_token {
            try Failure.wrap("Failed to store refresh token in Keychain") {
                try keychain.write(refreshToken, key: Self.refreshTokenKey)
            }
        }

        cacheAccessToken(response)
    }

    // MARK: - Token management

    private func validAccessToken() async throws -> String {
        if let token = cachedAccessToken, Date() < accessTokenExpiresAt.addingTimeInterval(-60) {
            return token
        }

        if let refreshToken = try? keychain.read(key: Self.refreshTokenKey) {
            do {
                return try await refreshAccessToken(using: refreshToken)
            } catch {
                // Refresh token revoked or invalid — clear and require re-auth
                try? keychain.delete(key: Self.refreshTokenKey)
                cachedAccessToken = nil
            }
        }

        throw Failure("Google is not authorized. Visit /auth/\(serviceID) to authorize.")
    }

    private func refreshAccessToken(using refreshToken: String) async throws -> String {
        let body = formEncode([
            "client_id": credentials.clientID,
            "client_secret": credentials.clientSecret,
            "refresh_token": refreshToken,
            "grant_type": "refresh_token"
        ])

        let request = try urlRequest(tokenURI: credentials.tokenURI, body: body)
        let (data, urlResponse) = try await Failure.wrap("Token refresh request failed") {
            try await URLSession.shared.data(for: request)
        }
        try validateTokenResponse(data, urlResponse, context: "Token refresh failed")
        let response = try Failure.wrap("Failed to decode token refresh response") {
            try JSONDecoder().decode(TokenResponse.self, from: data)
        }

        cacheAccessToken(response)
        return response.access_token
    }

    private func exchangeCodeForTokens(code: String, codeVerifier: String) async throws -> TokenResponse {
        let body = formEncode([
            "code": code,
            "client_id": credentials.clientID,
            "client_secret": credentials.clientSecret,
            "redirect_uri": redirectURI,
            "grant_type": "authorization_code",
            "code_verifier": codeVerifier
        ])

        let request = try urlRequest(tokenURI: credentials.tokenURI, body: body)
        let (data, urlResponse) = try await Failure.wrap("Token exchange request failed") {
            try await URLSession.shared.data(for: request)
        }
        try validateTokenResponse(data, urlResponse, context: "Token exchange failed")
        return try Failure.wrap("Failed to decode token exchange response") {
            try JSONDecoder().decode(TokenResponse.self, from: data)
        }
    }

    private func cacheAccessToken(_ response: TokenResponse) {
        cachedAccessToken = response.access_token
        accessTokenExpiresAt = Date().addingTimeInterval(Double(response.expires_in ?? 3600))
    }

    // MARK: - PKCE

    private func makePKCE() -> (verifier: String, challenge: String) {
        var bytes = [UInt8](repeating: 0, count: 32)
        _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        let verifier = Data(bytes).base64URLEncoded()
        let digest = SHA256.hash(data: Data(verifier.utf8))
        let challenge = Data(digest).base64URLEncoded()
        return (verifier, challenge)
    }

    private func pruneExpiredVerifiers() {
        let now = Date()
        pendingVerifiers = pendingVerifiers.filter {
            now.timeIntervalSince($0.value.createdAt) < Self.verifierTTL
        }
    }

    // MARK: - Auth URL

    private func buildAuthURL(codeChallenge: String, state: String) throws -> URL {
        guard var components = URLComponents(string: credentials.authURI) else {
            throw Failure("Invalid auth URI: \(credentials.authURI)")
        }
        components.queryItems = [
            URLQueryItem(name: "client_id", value: credentials.clientID),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: scopes.joined(separator: " ")),
            URLQueryItem(name: "code_challenge", value: codeChallenge),
            URLQueryItem(name: "code_challenge_method", value: "S256"),
            URLQueryItem(name: "state", value: state),
            URLQueryItem(name: "access_type", value: "offline"),
            URLQueryItem(name: "prompt", value: "consent")
        ]
        guard let url = components.url else {
            throw Failure("Failed to construct OAuth authorization URL")
        }
        return url
    }

    // MARK: - Helpers

    private func urlRequest(tokenURI: String, body: String) throws -> URLRequest {
        guard let url = URL(string: tokenURI) else {
            throw Failure("Invalid token URI: \(tokenURI)")
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = body.data(using: .utf8)
        return request
    }

    // MARK: - Response validation

    private func validateTokenResponse(_ data: Data, _ urlResponse: URLResponse, context: String) throws {
        guard let http = urlResponse as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            let errorBody = try? JSONDecoder().decode(ErrorResponse.self, from: data)
            let detail = errorBody?.error_description
                ?? errorBody?.error
                ?? String(data: data, encoding: .utf8)
                ?? "HTTP \((urlResponse as? HTTPURLResponse)?.statusCode ?? -1)"
            throw Failure("\(context): \(detail)")
        }
    }

    // MARK: - Decodable

    private struct TokenResponse: Decodable {
        let access_token: String
        let refresh_token: String?
        let expires_in: Int?
    }

    private struct ErrorResponse: Decodable {
        let error: String?
        let error_description: String?
    }
}
