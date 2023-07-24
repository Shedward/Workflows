//
//  SecureStorage.swift
//  Created by Vladislav Maltsev on 24.07.2023.
//

import Foundation

public protocol SecureStorage {
    associatedtype Account: SecureStorageAccount

    func saveSecret(_ secret: Data?, account: Account) throws
    func readSecret(for account: Account) throws -> Data?
}
