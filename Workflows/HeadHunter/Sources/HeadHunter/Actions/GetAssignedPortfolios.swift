//
//  GetAssignedPortfolios.swift
//
//
//  Created by v.maltsev on 04.09.2023.
//

import Jira
import RestClient

public struct GetAssignedPortfolios {
    public typealias Dependencies = JiraDependency

    let deps: Dependencies

    public init(deps: Dependencies) {
        self.deps = deps
    }
}

extension GetAssignedPortfolios: WorkflowAction {

    public struct Output {
        public let activePortfolios: PaginatingList<Portfolio>
    }

    public var title: String {
        "Получить assigned портфели"
    }


    public func perform(_ input: Void = ()) async throws -> Output {
        let query = JQLQuery(rawValue: "assignee = currentUser() AND type = Проект")

        let issues = try await deps.jira.searchIssues(jql: query, fields: SummaryFields.self)
        let portfolios = issues.map { issue in
            return Portfolio(
                key: issue.key,
                title: issue.fileds.summary
            )
        }

        return Output(
            activePortfolios: portfolios
        )
    }
}

private struct SummaryFields: IssueFields {
    let summary: String

    static let fieldKeys: [IssueFieldKey] = ["summary"]
}
