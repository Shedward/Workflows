//
//  LinkedIssueFields.swift
//
//
//  Created by v.maltsev on 12.09.2023.
//

public struct LinkedIssueFields: IssueFields {
    public let summary: String
    public let status: IssueStatus
    public let issuetype: IssueType
    public let priority: IssuePriority

    public static var fieldKeys: [IssueFieldKey] = [
        "summary", "status", "issuetype", "priority"
    ]
}
