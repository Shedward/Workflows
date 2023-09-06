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
    public typealias Dependencies = JiraDependency

    let deps: Dependencies
    let mainRepoConfig: MainRepositoryConfig

    public init(deps: Dependencies, mainRepoConfig: MainRepositoryConfig) {
        self.deps = deps
        self.mainRepoConfig = mainRepoConfig
    }
}

extension GetCurrentTask: WorkflowAction {

    public struct Output {
        public let task: Task
    }

    public var title: String {
        "Получить текущую таску"
    }

    public func perform(_ input: Void = ()) async throws -> Output {
        let ropository = try await Git().repository(at: mainRepoConfig.repositoryPath)
        let currentBranch = try await ropository.currentBranch()
        let issue = try await deps.jira.issue(key: currentBranch.rawValue, fields: SummaryFields.self)
        return Output(
            task: Task(key: issue.key, title: issue.fileds.summary, portfolio: nil)
        )
    }
}

private struct SummaryFields: IssueFields {
    let summary: String

    static let fieldKeys: [IssueFieldKey] = ["summary"]
}
