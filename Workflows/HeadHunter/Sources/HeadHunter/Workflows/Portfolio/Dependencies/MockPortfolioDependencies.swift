//
//  MockPortfolioDependencies.swift
//
//
//  Created by Vlad Maltsev on 23.12.2023.
//

import Git
import Jira
import Foundation

public struct MockPortfolioDependencies: PortfolioDependencies {
    public let gitMock: GitMock
    public let git: Git

    public let jiraMock: JiraMock
    public let jira: Jira
    
    public let configs: Configs
    
    public init() {
        let gitMock = GitMock()
        let git = Git(mock: gitMock)
        
        let jiraMock = JiraMock()
        let jira = Jira(mock: jiraMock)
        
        self.gitMock = gitMock
        self.git = git
        self.jiraMock = jiraMock
        self.jira = jira
        self.configs = Configs(
            jira: JiraConfig(
                host: URL(string: "https://mock.com")!,
                filters: .init(currentUserPortfolio: "currentUserPortfolio()")
            )
        )
    }
}
