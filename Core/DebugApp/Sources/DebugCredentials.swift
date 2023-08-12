//
//  DebugCredentials.swift
//  Created by Vladislav Maltsev on 24.07.2023.
//

import SecureStorage
import Prelude
import Jira

struct DebugCredentials {
    let secureStorage = SecItemStorage<DebugAppAccounts>(service: "me.shedward.workflows.DebugApp")

    enum DebugAppAccounts: String, SecureStorageAccount {
        case githubToken = "shedward@github"
        case jiraCredentials = "shedward@jira"
        case figmaToken = "shedward@figma"
    }

    func githubToken() throws -> String {
        guard let token = try secureStorage.readSecretString(for: .githubToken) else {
            throw Failure("No GitHub token in secure storage")
        }
        return token
    }

    func jiraCreds() throws -> JiraServerCredentials {
        guard let creds = try secureStorage.readSecretCodable(JiraServerCredentials.self, for: .jiraCredentials) else {
            throw Failure("No Jira creds in secure storage")
        }
        return creds
    }

    func figmaToken() throws -> String {
        guard let token = try secureStorage.readSecretString(for: .figmaToken) else {
            throw Failure("No Figma token in secure storage")
        }
        return token
    }
}
