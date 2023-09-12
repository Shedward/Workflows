//
//  IssueLink.swift
//
//
//  Created by v.maltsev on 12.09.2023.
//

import Prelude
import RestClient

public struct IssueLink: Decodable, Sendable {
    public let id: String
    public let type: LinkType
    public let inwardIssue: IssueDetails<LinkedIssueFields>?
    public let outwardIssue: IssueDetails<LinkedIssueFields>?
}
