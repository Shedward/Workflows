//
//  KeychainStorage.swift
//  Core
//

import Foundation
import Security

/// A generic `kSecClassGenericPassword` Keychain wrapper scoped to a service identifier.
public struct KeychainStorage: Sendable {
    public let service: String

    public init(service: String) {
        self.service = service
    }

    public func read(key: String) throws -> String? {
        let query: [CFString: Any] = [
            kSecClass:        kSecClassGenericPassword,
            kSecAttrService:  service,
            kSecAttrAccount:  key,
            kSecReturnData:   true,
            kSecMatchLimit:   kSecMatchLimitOne,
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        switch status {
        case errSecSuccess:
            guard let data = result as? Data,
                  let value = String(data: data, encoding: .utf8) else {
                throw Failure("Keychain item for '\(key)' is not valid UTF-8")
            }
            return value
        case errSecItemNotFound:
            return nil
        default:
            throw Failure("Keychain read failed for '\(key)' (OSStatus \(status))")
        }
    }

    public func write(_ value: String, key: String) throws {
        guard let data = value.data(using: .utf8) else {
            throw Failure("Cannot encode value for Keychain key '\(key)' as UTF-8")
        }

        if (try? read(key: key)) != nil {
            let query: [CFString: Any] = [
                kSecClass:       kSecClassGenericPassword,
                kSecAttrService: service,
                kSecAttrAccount: key,
            ]
            let update: [CFString: Any] = [kSecValueData: data]
            let status = SecItemUpdate(query as CFDictionary, update as CFDictionary)
            guard status == errSecSuccess else {
                throw Failure("Keychain update failed for '\(key)' (OSStatus \(status))")
            }
        } else {
            let attrs: [CFString: Any] = [
                kSecClass:       kSecClassGenericPassword,
                kSecAttrService: service,
                kSecAttrAccount: key,
                kSecValueData:   data,
            ]
            let status = SecItemAdd(attrs as CFDictionary, nil)
            guard status == errSecSuccess else {
                throw Failure("Keychain write failed for '\(key)' (OSStatus \(status))")
            }
        }
    }

    public func delete(key: String) throws {
        let query: [CFString: Any] = [
            kSecClass:       kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: key,
        ]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw Failure("Keychain delete failed for '\(key)' (OSStatus \(status))")
        }
    }
}
