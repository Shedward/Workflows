//
//  ActionPortfolioDependencies.swift
//
//
//  Created by Vlad Maltsev on 23.12.2023.
//

import Git

public struct ActionPortfolioDependencies: PortfolioDependencies {
    public let git: Git
    
    public init() {
        self.git = Git()
    }
}
