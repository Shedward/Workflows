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

        let body = "grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer&assertion=\(jwt)"
        let urlRequest: URLRequest = {
            var r = URLRequest(url: url)
            r.httpMethod = "POST"
            r.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            r.httpBody = body.data(using: .utf8)
            return r
        }()

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
        // Strip PEM headers and decode base64 to get DER bytes
        let lines = pem.components(separatedBy: .newlines)
            .filter { !$0.hasPrefix("-----") && !$0.isEmpty }
        guard let der = Data(base64Encoded: lines.joined()) else {
            throw Failure("Failed to base64-decode PEM private key")
        }

        // Google service account keys are PKCS#8. SecKeyCreateWithData expects PKCS#1.
        // Extract the inner PKCS#1 RSA key from the PKCS#8 wrapper.
        let pkcs1 = try extractPKCS1FromPKCS8(der)

        let attrs: [CFString: Any] = [
            kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass: kSecAttrKeyClassPrivate,
        ]
        var cfError: Unmanaged<CFError>?
        guard let key = SecKeyCreateWithData(pkcs1 as CFData, attrs as CFDictionary, &cfError) else {
            let error = cfError?.takeRetainedValue()
            throw Failure("Failed to create RSA key", underlyingError: error.map { $0 as Error })
        }
        return key
    }

    /// Extracts the inner PKCS#1 RSA key bytes from a PKCS#8 DER-encoded wrapper.
    /// PKCS#8: SEQUENCE { INTEGER(0), SEQUENCE { OID, NULL }, OCTET STRING { <pkcs1> } }
    private func extractPKCS1FromPKCS8(_ der: Data) throws -> Data {
        var i = 0

        func readTag() throws -> UInt8 {
            guard i < der.count else { throw Failure("Unexpected end of DER data") }
            let tag = der[i]; i += 1
            return tag
        }

        func readLength() throws -> Int {
            guard i < der.count else { throw Failure("Unexpected end of DER data at length") }
            let first = Int(der[i]); i += 1
            if first < 0x80 { return first }
            let numBytes = first & 0x7F
            guard numBytes > 0, i + numBytes <= der.count else { throw Failure("Invalid DER length") }
            var length = 0
            for _ in 0..<numBytes { length = (length << 8) | Int(der[i]); i += 1 }
            return length
        }

        func skipValue() throws {
            let len = try readLength()
            guard i + len <= der.count else { throw Failure("DER value out of bounds") }
            i += len
        }

        // outer SEQUENCE tag + length (just advance past them)
        guard try readTag() == 0x30 else { throw Failure("Expected outer SEQUENCE in PKCS#8") }
        _ = try readLength()

        // INTEGER (version = 0)
        guard try readTag() == 0x02 else { throw Failure("Expected INTEGER in PKCS#8") }
        try skipValue()

        // SEQUENCE (AlgorithmIdentifier)
        guard try readTag() == 0x30 else { throw Failure("Expected AlgorithmIdentifier SEQUENCE") }
        try skipValue()

        // OCTET STRING containing the PKCS#1 key
        guard try readTag() == 0x04 else { throw Failure("Expected OCTET STRING in PKCS#8") }
        let keyLen = try readLength()
        guard i + keyLen <= der.count else { throw Failure("PKCS#1 key data out of bounds") }
        return der[i..<(i + keyLen)]
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
