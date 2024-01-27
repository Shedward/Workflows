//
//  MockPortfolioDependencies.swift
//
//
//  Created by Vlad Maltsev on 23.12.2023.
//

import Git
import Jira
import Foundation
import LocalStorage
import FileSystem

public struct MockPortfolioDependencies: PortfolioDependencies {
    public let gitMock: GitMock
    public let git: Git

    public let jiraMock: JiraMock
    public let jira: Jira
    
    public let configStorage: CodableStorage
    public let configs: Configs
    
    public let fileSystem: FileSystem
    
    public init() {
        let gitMock = GitMock()
        let git = Git(mock: gitMock)
        
        let jiraMock = JiraMock()
        let jira = Jira(mock: jiraMock)
        
        let configStorage = InMemoryCodableStorage()
        
        self.gitMock = gitMock
        self.git = git
        self.jiraMock = jiraMock
        self.jira = jira
        self.configStorage = configStorage
        self.configs = Configs(configStorage: configStorage)
        self.fileSystem = InMemoryFileSystem()
    }
}
