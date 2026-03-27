//
//  ServiceAccountCredentials.swift
//  GoogleServices
//

import Core
import Foundation

public struct ServiceAccountCredentials: Codable, Sendable {
    public let clientEmail: String
    public let privateKeyPem: String
    public let tokenUri: String

    enum CodingKeys: String, CodingKey {
        case clientEmail = "client_email"
        case privateKeyPem = "private_key"
        case tokenUri = "token_uri"
    }

    public static func load(from path: String) throws -> ServiceAccountCredentials {
        let url = URL(fileURLWithPath: path)
        let data = try Failure.wrap("Failed to read service account key at \(path)") {
            try Data(contentsOf: url)
        }
        return try Failure.wrap("Failed to parse service account JSON") {
            try JSONDecoder().decode(ServiceAccountCredentials.self, from: data)
        }
    }
}
