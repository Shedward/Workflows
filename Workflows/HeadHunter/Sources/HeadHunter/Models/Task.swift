//
//  Moba.swift
//
//
//  Created by v.maltsev on 06.09.2023.
//

import Jira

public struct Task {
    public let key: String
    public let type: String
    public let title: String
    public let status: String

    public let portfolio: Portfolio?

    init(key: String, type: String, title: String, status: String, portfolio: Portfolio?) {
        self.key = key
        self.title = title
        self.type = type
        self.portfolio = portfolio
        self.status = status
    }

    init(issue: IssueWithFields<TaskIssueFields>) {
        self.init(
            key: issue.key,
            type: issue.fileds.issuetype.name,
            title: issue.fileds.summary,
            status: issue.fileds.status.name,
            portfolio: issue.links().consistsIn().first.map { parrentIssue in
                Portfolio(
                    key: parrentIssue.key,
                    title: parrentIssue.fileds.summary,
                    status: parrentIssue.fileds.status.name
                )
            }
        )
    }
}
