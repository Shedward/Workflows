//
//  Configs.swift
//
//
//  Created by Vlad Maltsev on 18.01.2024.
//

import LocalStorage

public final class Configs {
    private let configStorage: CodableStorage
    
    public init(configStorage: CodableStorage) {
        self.configStorage = configStorage
    }
    
    public func jira() throws -> JiraConfig {
        try configStorage.load(JiraConfig.self, at: "jira")
    }
    
    public func git() throws -> GitConfig {
        try configStorage.load(GitConfig.self, at: "git")
    }
}
