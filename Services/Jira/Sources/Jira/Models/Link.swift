//
//  Link.swift
//
//
//  Created by v.maltsev on 12.09.2023.
//

import Prelude

public struct Links {
    private let client: JiraClient

    public let issueId: String
    public let issueKey: String
    private let links: [IssueLink]

    internal init<Fields: IssueFieldsWithLinks>(client: JiraClient, issue: IssueWithFields<Fields>) {
        self.client = client
        self.issueId = issue.id
        self.issueKey = issue.key
        self.links = issue.fileds.issuelinks
    }

    public func consistsIn() -> [IssueWithFields<LinkedIssueFields>] {
        links
            .filter { $0.type.inward == "consists in" }
            .compactMap { link in
                guard let inwardIssue = link.inwardIssue else { return nil }
                return IssueWithFields(response: inwardIssue, client: client)
            }
    }

    public func includes() -> [IssueWithFields<LinkedIssueFields>] {
        links
            .filter { $0.type.outward == "includes" }
            .compactMap { link in
                guard let outwardIssue = link.outwardIssue else { return nil }
                return IssueWithFields(response: outwardIssue, client: client)
            }
    }
}
