//
//  AssignedPortfolios.swift
//
//
//  Created by v.maltsev on 04.09.2023.
//

import Jira
import RestClient

public struct AssignedPortfolios {
    public typealias Dependencies = JiraDependency

    let deps: Dependencies

    public init(deps: Dependencies) {
        self.deps = deps
    }

    public func load() async throws -> PaginatingList<Portfolio> {
        let query = JQLQuery(rawValue: "assignee = currentUser() AND type = Проект")

        struct SummaryFields: IssueFields {
            let summary: String

            static func fieldKeys() -> [IssueFieldKey] {
                ["summary"]
            }
        }

        let issues = try await deps.jira.searchIssues(jql: query, fields: SummaryFields.self)
        let portfolios = issues.map { issue in
            return Portfolio(
                key: issue.key,
                title: issue.fileds.summary
            )
        }
        return portfolios
    }
}
