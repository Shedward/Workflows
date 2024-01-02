//
//  PortfolioDependencies.swift
//  
//
//  Created by Vlad Maltsev on 23.12.2023.
//

import Git

public protocol PortfolioDependencies {
    var git: Git { get }
}
