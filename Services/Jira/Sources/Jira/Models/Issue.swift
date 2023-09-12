//
//  IssueWithFields.swift
//  Created by Vladislav Maltsev on 26.07.2023.
//

import Prelude

public typealias Issue = IssueWithFields<CodableVoid>

public struct IssueWithFields<Fields: IssueFields> {
    public let id: String
    public let key: String
    public let fileds: Fields

    internal let client: JiraClient

    internal init(response: IssueDetails<Fields>, client: JiraClient) {
        self.id = response.id
        self.key = response.key
        self.fileds = response.fields

        self.client = client
    }
}

extension IssueWithFields where Fields: IssueFieldsWithLinks {
    public func links() -> Links {
        Links(client: client, issue: self)
    }
}

extension IssueWithFields: Identifiable {
}
