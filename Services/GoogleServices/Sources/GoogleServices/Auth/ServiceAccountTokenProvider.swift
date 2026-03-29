//
//  ServiceAccountTokenProvider.swift
//  GoogleServices
//

import Core
import Foundation
import Rest
import Security

public actor ServiceAccountTokenProvider: AccessTokenAuthorizer {
    private let credentials: ServiceAccountCredentials
    private let scopes: [String]
    private var cachedToken: String?
    private var tokenExpiresAt: Date = .distantPast

    public init(credentials: ServiceAccountCredentials, scopes: [String]) {
        self.credentials = credentials
        self.scopes = scopes
    }

    public func authorizationHeaders() async throws -> Headers {
        if let token = cachedToken, Date() < tokenExpiresAt.addingTimeInterval(-60) {
            return bearer(token)
        }
        let token = try await fetchToken()
        cachedToken = token
        tokenExpiresAt = Date().addingTimeInterval(3600)
        return bearer(token)
    }

    // MARK: - Token fetch

    private func fetchToken() async throws -> String {
        let jwt = try buildJWT()

        guard let url = URL(string: credentials.tokenUri) else {
            throw Failure("Invalid token URI: \(credentials.tokenUri)")
        }

        let body = formEncode([
            "grant_type": "urn:ietf:params:oauth:grant-type:jwt-bearer",
            "assertion": jwt
        ])
        let urlRequest: URLRequest = {
            var req = URLRequest(url: url)
            req.httpMethod = "POST"
            req.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            req.httpBody = body.data(using: .utf8)
            return req
        }()

        let (data, urlResponse) = try await Failure.wrap("Failed to exchange JWT for access token") {
            try await URLSession.shared.data(for: urlRequest)
        }
        try validateTokenResponse(data, urlResponse)

        struct TokenResponse: Decodable {
            let access_token: String
        }

        return try Failure.wrap("Failed to decode token response") {
            try JSONDecoder().decode(TokenResponse.self, from: data).access_token
        }
    }

    // MARK: - JWT building

    private struct JWTHeader: Encodable {
        let alg = "RS256"
        let typ = "JWT"
    }

    private struct JWTPayload: Encodable {
        let iss: String
        let scope: String
        let aud: String
        let iat: Int
        let exp: Int
    }

    private func buildJWT() throws -> String {
        let header = try base64urlEncoded(JWTHeader())
        let now = Int(Date().timeIntervalSince1970)
        let payload = try base64urlEncoded(JWTPayload(
            iss: credentials.clientEmail,
            scope: scopes.joined(separator: " "),
            aud: credentials.tokenUri,
            iat: now,
            exp: now + 3600
        ))

        let signingInput = "\(header).\(payload)"
        let key = try loadPrivateKey(from: credentials.privateKeyPem)
        let signature = try rsaSign(Data(signingInput.utf8), with: key)
        return "\(signingInput).\(signature.base64URLEncoded())"
    }

    private func base64urlEncoded<T: Encodable>(_ value: T) throws -> String {
        let data = try Failure.wrap("Failed to encode JWT component") {
            try JSONEncoder().encode(value)
        }
        return data.base64URLEncoded()
    }

    // MARK: - Response validation

    private func validateTokenResponse(_ data: Data, _ urlResponse: URLResponse) throws {
        guard let http = urlResponse as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            struct ErrorResponse: Decodable { let error: String?; let error_description: String? }
            let errorBody = try? JSONDecoder().decode(ErrorResponse.self, from: data)
            let detail = errorBody?.error_description
                ?? errorBody?.error
                ?? String(data: data, encoding: .utf8)
                ?? "HTTP \((urlResponse as? HTTPURLResponse)?.statusCode ?? -1)"
            throw Failure("Token request failed: \(detail)")
        }
    }

    // MARK: - RSA signing

    private func loadPrivateKey(from pem: String) throws -> SecKey {
        guard let pemData = pem.data(using: .utf8) else {
            throw Failure("PEM private key is not valid UTF-8")
        }
        var format = SecExternalFormat.formatPEMSequence
        var type = SecExternalItemType.itemTypePrivateKey
        var outItems: CFArray?
        let status = SecItemImport(
            pemData as CFData,
            nil,    // fileName — format inferred from content
            &format,
            &type,
            [],     // flags
            nil,    // keyParams — no passphrase
            nil,    // importKeychain — nil means don't store in Keychain
            &outItems
        )
        guard status == errSecSuccess,
              let items = outItems as? [SecKey],
              let key = items.first else {
            throw Failure("Failed to import RSA private key from PEM (OSStatus \(status))")
        }
        return key
    }

    private func rsaSign(_ data: Data, with key: SecKey) throws -> Data {
        var cfError: Unmanaged<CFError>?
        guard let signature = SecKeyCreateSignature(
            key,
            .rsaSignatureMessagePKCS1v15SHA256,
            data as CFData,
            &cfError
        ) else {
            let error = cfError?.takeRetainedValue()
            throw Failure("RS256 signing failed", underlyingError: error.map { $0 as Error })
        }
        return signature as Data
    }
}
