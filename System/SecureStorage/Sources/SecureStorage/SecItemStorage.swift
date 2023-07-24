//
//  SecItemStorage.swift
//  Created by Vladislav Maltsev on 24.07.2023.
//

import Foundation
import Prelude

public final class SecItemStorage<Account: SecureStorageAccount>: SecureStorage {

    private let service: String
    private let shouldSyncronizeWithCloud: Bool = false

    public init(service: String) {
        self.service = service
    }

    public func saveSecret(_ secret: Data?, account: Account) throws {
        var status: OSStatus

        if let secret {
            status = save(secret: secret, account: account.rawValue)

            if status == errSecDuplicateItem {
                status = update(secret: secret, account: account.rawValue)
            }
        } else {
            status = deleteSecret(account: account.rawValue)

            if status == errSecItemNotFound {
                return
            }
        }

        try unwrapError(from: status)
    }

    public func readSecret(for account: Account) throws -> Data? {
        let (status, secret) = readSecret(account: account.rawValue)

        if status == errSecItemNotFound {
            return nil
        }

        try unwrapError(from: status)

        guard let secret = secret as? Data else {
            throw Failure("Tried to read secret in wrong format")
        }

        return secret
    }

    private func save(secret: Data, account: String) -> OSStatus {
        var query: [String: AnyObject] = [
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecClass as String: kSecClassGenericPassword,
            kSecValueData as String: secret as AnyObject
        ]

        if shouldSyncronizeWithCloud {
            query[kSecAttrSynchronizable as String] = kCFBooleanTrue
        }

        let status = SecItemAdd(query as CFDictionary, nil)

        return status
    }

    private func update(secret: Data, account: String) -> OSStatus {
        var query: [String: AnyObject] = [
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecClass as String: kSecClassGenericPassword
        ]

        if shouldSyncronizeWithCloud {
            query[kSecAttrSynchronizable as String] = kCFBooleanTrue
        }

        let attributes: [String: AnyObject] = [
            kSecValueData as String: secret as AnyObject
        ]

        let status = SecItemUpdate(
            query as CFDictionary,
            attributes as CFDictionary
        )

        return status
    }

    private func readSecret(account: String) -> (OSStatus, AnyObject?) {
        var query: [String: AnyObject] = [
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecClass as String: kSecClassGenericPassword,

            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: kCFBooleanTrue
        ]

        if shouldSyncronizeWithCloud {
            query[kSecAttrSynchronizable as String] = kCFBooleanTrue
        }

        var itemCopy: AnyObject?
        let status = SecItemCopyMatching(
            query as CFDictionary,
            &itemCopy
        )

        return (status, itemCopy)
    }

    private func deleteSecret(account: String) -> OSStatus {
        var query: [String: AnyObject] = [
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecClass as String: kSecClassGenericPassword
        ]

        if shouldSyncronizeWithCloud {
            query[kSecAttrSynchronizable as String] = kCFBooleanTrue
        }

        let status = SecItemDelete(query as CFDictionary)

        return status
    }

    private func unwrapError(from status: OSStatus) throws {
        switch status {
        case errSecSuccess:
            return
        case errSecItemNotFound:
            throw Failure("Secret not found")
        case errSecDuplicateItem:
            throw Failure("Secret already exists")
        default:
            throw Failure("Unexpected operation status \(status)")
        }
    }
}
