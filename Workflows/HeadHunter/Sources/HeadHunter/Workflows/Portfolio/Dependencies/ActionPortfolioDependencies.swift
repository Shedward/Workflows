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
    public let fileSystem: FileSystem
    
    public init() throws {
        let secureStorage = SecItemStorage<Accounts>(service: "me.shedward.workflows")
        let fileSystem = FileManagerFileSystem()
        let configStorage = DirectoryCodableStorage(at: fileSystem.homeDirectory().appending(".workflows/hh"))
        
        let configs = Configs(configStorage: configStorage)
        let jiraConfig = try configs.jira()
        let authorizer = JiraAuthorizer(credentialsStorage: secureStorage.accessor(for: .jira))

        self.git = Git()
        self.jira = Jira(serverHost: jiraConfig.host, authorizer: authorizer)
        self.configs = configs
        self.fileSystem = FileManagerFileSystem()
    }
}
