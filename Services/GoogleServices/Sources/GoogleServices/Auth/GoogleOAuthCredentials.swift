//
//  GoogleOAuthCredentials.swift
//  GoogleServices
//

import Core
import Foundation

/// OAuth 2.0 client credentials for a GCP "Desktop app" client.
/// Load from the JSON file downloaded from GCP Console → APIs & Services → Credentials.
public struct GoogleOAuthCredentials: Sendable {
    public let clientID: String
    public let clientSecret: String
    public let authURI: String
    public let tokenURI: String

    /// Loads from `~/.workflows/google_cloud/oauth_client.json`.
    public static func loadDefault() throws -> GoogleOAuthCredentials {
        let url = FileManager.default
            .homeDirectoryForCurrentUser
            .appending(path: ".workflows/google_cloud/oauth_client.json")
        return try load(from: url)
    }

    public static func load(from url: URL) throws -> GoogleOAuthCredentials {
        let data = try Failure.wrap("Failed to read OAuth client JSON at \(url.path)") {
            try Data(contentsOf: url)
        }
        let raw = try Failure.wrap("Failed to parse OAuth client JSON") {
            try JSONDecoder().decode(RawFile.self, from: data)
        }
        return GoogleOAuthCredentials(
            clientID: raw.installed.client_id,
            clientSecret: raw.installed.client_secret,
            authURI: raw.installed.auth_uri,
            tokenURI: raw.installed.token_uri
        )
    }
}

// MARK: - GCP Console JSON shape

private extension GoogleOAuthCredentials {
    struct RawFile: Decodable {
        let installed: Entry
    }

    struct Entry: Decodable {
        let client_id: String
        let client_secret: String
        let auth_uri: String
        let token_uri: String
    }
}
