//
//  GetAssignedPortfolios.swift
//
//
//  Created by v.maltsev on 04.09.2023.
//

import Prelude
import Jira
import RestClient

public struct GetAssignedTasks {
    public typealias Dependencies = JiraDependency

    let deps: Dependencies

    public init(deps: Dependencies) {
        self.deps = deps
    }
}

extension GetAssignedTasks: WorkflowAction {

    public struct Output {
        public let assignedTasks: PaginatingList<Task>
    }

    public var title: String {
        "Получить все таски"
    }

    public func perform(_ input: Void = ()) async throws -> Output {
        let query = JQLQuery(rawValue: "assignee = currentUser() AND type in (Task, Bug) AND statusCategory != Done")

        let issues = try await deps.jira.searchIssues(jql: query, fields: TaskIssueFields.self)
        let tasks = issues.map(HeadHunter.Task.init)

        return Output(
            assignedTasks: tasks
        )
    }
}
