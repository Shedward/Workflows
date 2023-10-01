//
//  GetCurrentTask.swift
//
//
//  Created by v.maltsev on 06.09.2023.
//

import Foundation
import Git
import Jira

public struct GetCurrentTask {
    public typealias Dependencies = JiraDependency & GitDependency

    let deps: Dependencies
    let mainRepoConfig: MainRepositoryConfig

    public init(deps: Dependencies, mainRepoConfig: MainRepositoryConfig) {
        self.deps = deps
        self.mainRepoConfig = mainRepoConfig
    }
}

extension GetCurrentTask: WorkflowAction {

    public struct Output {
        public let task: HeadHunter.Task
    }

    public var title: String {
        "Получить текущую таску"
    }

    public func perform(_ input: Void = ()) async throws -> Output {
        let repository = try await deps.git.repository(at: mainRepoConfig.repositoryPath)
        let currentBranch = try await repository.currentBranch()
        let issue = try await deps.jira.issue(key: currentBranch.rawValue, fields: TaskIssueFields.self)
        return Output(task: .init(issue: issue))
    }
}
