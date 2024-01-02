//
//  MockPortfolioDependencies.swift
//
//
//  Created by Vlad Maltsev on 23.12.2023.
//

import Git

public struct MockPortfolioDependencies: PortfolioDependencies {
    public let gitMock: GitMock
    public let git: Git
    
    public init() {
        let gitMock = GitMock()
        let git = Git(mock: gitMock)
        
        self.gitMock = gitMock
        self.git = git
    }
}
