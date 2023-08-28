//
//  NetworkDependencies.swift
//
//
//  Created by v.maltsev on 29.08.2023.
//

import GoogleCloud
import SecureStorage
import LocalStorage

public struct NetworkDependencies: AllDependencies {
    public var configStorage: ConfigStorage
    public var googleDrive: GoogleCloud.GoogleDrive
    public var googleSheets: GoogleCloud.GoogleSheets

    public init() throws {
        self.configStorage = FileConfigStorage()
        
        let secureStorage = SecItemStorage<SecureStorageAccounts>(service: "me.workflows.OAuthHelper")
        let authorizer = Authorizer(
            request: try configStorage.load(at: "google-authorizer"),
            tokensStorage: secureStorage.accessor(for: .google)
        )

        self.googleDrive = GoogleDrive(authorizer: authorizer)
        self.googleSheets = GoogleSheets(authorizer: authorizer)
    }
}

private enum SecureStorageAccounts: String, SecureStorageAccount {
    case google
}
