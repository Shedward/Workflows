//
//  ActionPortfolioDependencies.swift
//
//
//  Created by Vlad Maltsev on 23.12.2023.
//

import Git
import Jira
import SecureStorage
import LocalStorage
import FileSystem
import Prelude

public struct ActionPortfolioDependencies: PortfolioDependencies {
    public let git: Git
    public let jira: Jira
    public let configs: Configs
    
    public init() throws {
        let secureStorage = SecItemStorage<Accounts>(service: "me.shedward.workflows")
        let fileSystem = FileManagerFileSystem()
        let configStorage = DirectoryCodableStorage(at: fileSystem.homeDirectory().appending(".workflows/hh"))
        
        let jiraConfig = try configStorage.load(JiraConfig.self, at: "jira")
        guard let jiraCreds = try secureStorage.readSecretCodable(JiraServerCredentials.self, for: .jira) else {
            throw Failure("Credentials for jira not found")
        }
        
        self.git = Git()
        self.jira = try Jira(serverHost: jiraConfig.host, credentials: jiraCreds)
        self.configs = Configs(jira: jiraConfig)
    }
}
