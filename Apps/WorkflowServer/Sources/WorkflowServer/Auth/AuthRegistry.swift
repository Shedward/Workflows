//
//  AuthRegistry.swift
//  WorkflowServer
//

import Rest

/// Holds all registered OAuth providers by their `serviceID`.
/// Used by `AuthController` to serve `/auth` endpoints.
public actor AuthRegistry {
    private var providers: [String: any OAuthProvider] = [:]

    public var allProviders: [any OAuthProvider] {
        Array(providers.values)
    }

    public init() {}

    public func register(_ provider: any OAuthProvider) {
        providers[provider.serviceID] = provider
    }

    public func provider(for serviceID: String) -> (any OAuthProvider)? {
        providers[serviceID]
    }
}
