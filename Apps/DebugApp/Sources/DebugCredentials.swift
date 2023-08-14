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
        case googleKey = "shedward@google"
        case googleAccessToken = "shedward-access@google"
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

    func googleKey() throws -> String {
        guard let token = try secureStorage.readSecretString(for: .googleKey) else {
            throw Failure("No Google token in secure storage")
        }
        return token
    }

    func googleAccessToken() throws -> String {
        guard let token = try secureStorage.readSecretString(for: .googleAccessToken) else {
            throw Failure("No Google Access Token in secure storage")
        }
        return token
    }
}
