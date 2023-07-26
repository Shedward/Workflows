//
//  Issue.swift
//  Created by Vladislav Maltsev on 26.07.2023.
//

public struct Issue {
    public let id: String
    public let key: String

    private let client: JiraClient

    init(response: IssueResponse, client: JiraClient) {
        self.id = response.id
        self.key = response.key

        self.client = client
    }
}
