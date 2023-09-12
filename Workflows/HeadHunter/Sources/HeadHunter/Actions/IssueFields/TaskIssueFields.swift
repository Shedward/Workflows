//
//  TaskIssueFields.swift
//  
//
//  Created by v.maltsev on 12.09.2023.
//

import Jira

struct TaskIssueFields: IssueFields, IssueFieldsWithLinks {
    let summary: String
    let issuelinks: [IssueLink]
    let status: IssueStatus
    let issuetype: IssueType
    let priority: IssuePriority

    static let fieldKeys: [IssueFieldKey] = [
        "summary", "issuelinks", "issuetype", "status", "priority"
    ]
}
