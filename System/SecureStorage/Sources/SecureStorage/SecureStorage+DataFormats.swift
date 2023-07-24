//
//  SecureStorage+DataFormats.swift
//  Created by Vladislav Maltsev on 24.07.2023.
//

import Foundation
import Prelude

extension SecureStorage {
    public func readSecretString(for account: Account, encoding: String.Encoding = .utf8) throws -> String? {
        guard let data = try readSecret(for: account) else {
            return nil
        }

        guard let string = String(data: data, encoding: encoding) else {
            throw Failure("Failed to decode secret as a String")
        }

        return string
    }

    public func saveSecretString(_ secretString: String, for account: Account, encoding: String.Encoding = .utf8) throws {
        guard let data = secretString.data(using: encoding) else {
            throw Failure("Failed to encode secret as a String")
        }

        try saveSecret(data, account: account)
    }

    public func readSecretCodable<Model: Codable>(_ type: Model.Type, for account: Account) throws -> Model? {
        guard let data = try readSecret(for: account) else {
            return nil
        }

        let model = try Failure.wrap("Trying to decode \(Model.self)") {
            try JSONDecoder().decode(Model.self, from: data)
        }

        return model
    }

    public func saveSecretCodable<Model: Codable>(secret: Model?, for account: Account) throws {
        guard let secret else {
            try saveSecret(nil, account: account)
            return
        }

        let data = try Failure.wrap("Trying to encode \(Model.self)") {
            try JSONEncoder().encode(secret)
        }

        try saveSecret(data, account: account)
    }
}
