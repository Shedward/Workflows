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

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let body = "grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer&assertion=\(jwt)"
        urlRequest.httpBody = body.data(using: .utf8)

        let (data, _) = try await Failure.wrap("Failed to exchange JWT for access token") {
            try await URLSession.shared.data(for: urlRequest)
        }

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
        return "\(signingInput).\(base64url(signature))"
    }

    private func base64urlEncoded<T: Encodable>(_ value: T) throws -> String {
        let data = try Failure.wrap("Failed to encode JWT component") {
            try JSONEncoder().encode(value)
        }
        return base64url(data)
    }

    private func base64url(_ data: Data) -> String {
        data.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }

    // MARK: - RSA signing

    private func loadPrivateKey(from pem: String) throws -> SecKey {
        let pemData = Data(pem.utf8) as CFData
        var format = SecExternalFormat.formatPEMSequence
        var type = SecExternalItemType.itemTypePrivateKey
        var outItems: CFArray?

        let status = SecItemImport(
            pemData, nil, &format, &type,
            SecItemImportExportFlags(rawValue: 0),
            nil, nil, &outItems
        )

        guard status == errSecSuccess else {
            throw Failure("Failed to import private key: OSStatus \(status)")
        }

        guard let items = outItems as? [AnyObject],
              let key = items.first as? SecKey else {
            throw Failure("No private key found in PEM data")
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
