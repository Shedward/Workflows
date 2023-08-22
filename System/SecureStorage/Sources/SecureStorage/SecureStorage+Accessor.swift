//
//  SecureStorage+Accessor.swift
//
//
//  Created by v.maltsev on 22.08.2023.
//

import Foundation
import Prelude

extension SecureStorage {
    public func accessor(for account: Account) -> ThrowingAccessor<Data?> {
        ThrowingAccessor(
            get: {
                try readSecret(for: account)
            },
            set: {
                try saveSecret($0, account: account)
            }
        )
    }
}
