//
//  DebugCredentials.swift
//  Created by Vladislav Maltsev on 24.07.2023.
//

import SecureStorage
import Prelude

struct DebugCredentials {
    let secureStorage = SecItemStorage<DebugAppAccounts>(service: "me.shedward.workflows.DebugApp")

    enum DebugAppAccounts: String, SecureStorageAccount {
        case githubToken = "shedward@github"
        case jiraCredentials = "shedward@jira"
    }

    func githubToken() throws -> String {
        guard let token = try secureStorage.readSecretString(for: .githubToken) else {
            throw Failure("No GitHub token in secure storage")
        }
        return token
    }

    func jiraCreds() throws -> JiraCredentials {
        guard let creds = try secureStorage.readSecretCodable(JiraCredentials.self, for: .jiraCredentials) else {
            throw Failure("No Jira creds in secure storage")
        }
        return creds
    }
}
