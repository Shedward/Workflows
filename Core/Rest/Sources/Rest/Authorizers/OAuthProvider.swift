//
//  OAuthProvider.swift
//  Rest
//

import Foundation

/// An OAuth2 provider that manages the authorization flow for a specific service.
/// Lives alongside `AccessTokenAuthorizer` — implement both on the same type
/// to get a token provider that can also participate in the `/auth` endpoints.
public protocol OAuthProvider: Sendable {
    /// Short identifier used in URL paths, e.g. `"google"` → `/auth/google`.
    var serviceID: String { get }

    /// Human-readable name shown in auth status listings.
    var displayName: String { get }

    /// Returns `true` if a valid refresh token is available.
    func isAuthorized() async -> Bool

    /// Builds the authorization URL the user should visit to grant access.
    /// Generates and stores a PKCE verifier keyed by the returned URL's `state` parameter.
    func authorizationURL() async throws -> URL

    /// Exchanges an authorization code for tokens and persists the refresh token.
    /// - Parameters:
    ///   - code: The authorization code from the OAuth callback.
    ///   - state: The `state` value echoed back by the authorization server;
    ///            must match the one generated in `authorizationURL()`.
    func handleCallback(code: String, state: String) async throws
}
