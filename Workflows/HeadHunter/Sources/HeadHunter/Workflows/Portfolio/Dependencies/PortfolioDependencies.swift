//
//  PortfolioDependencies.swift
//  
//
//  Created by Vlad Maltsev on 23.12.2023.
//

import Git
import Jira

public protocol PortfolioDependencies {
    var git: Git { get }
    var jira: Jira { get }
    
    var configs: Configs { get }
}
