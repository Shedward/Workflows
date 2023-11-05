//
//  NetworkDependencies.swift
//
//
//  Created by v.maltsev on 29.08.2023.
//

import GoogleCloud
import SecureStorage
import LocalStorage
import Jira
import Git
import FileSystem

public struct NetworkDependencies: AllDependencies {
    public var configStorage: CodableStorage

    public var googleDrive: GoogleCloud.GoogleDrive
    public var googleSheets: GoogleCloud.GoogleSheets
    public var googleAuthorizer: GoogleAuthorizer

    public var jiraAuthorizer: JiraAuthorizer
    public var jira: Jira
    
    public var git: Git

    public init() throws {
        let fileSystem = FileManagerFileSystem()
        self.configStorage = DirectoryCodableStorage(at: fileSystem.homeDirectory().appending(".workflows"))

        let secureStorage = SecItemStorage<SecureStorageAccounts>(service: "me.workflows.Workflows")

        self.googleAuthorizer = GoogleAuthorizer(
            request: try configStorage.load(at: "google"),
            tokensStorage: secureStorage.accessor(for: .google)
        )
        self.googleDrive = GoogleDrive(authorizer: googleAuthorizer)
        self.googleSheets = GoogleSheets(authorizer: googleAuthorizer)

        let jiraConfig = try configStorage.load(JiraConfig.self, at: "jira")
        self.jiraAuthorizer = JiraAuthorizer(credentialsStorage: secureStorage.accessor(for: .jira))
        self.jira = Jira(serverHost: jiraConfig.host, authorizer: jiraAuthorizer)
        
        self.git = Git()
    }
}

private enum SecureStorageAccounts: String, SecureStorageAccount {
    case google
    case jira
}
