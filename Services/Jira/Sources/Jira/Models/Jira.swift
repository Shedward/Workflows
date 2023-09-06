//
//  Jira.swift
//  Created by Vladislav Maltsev on 26.07.2023.
//

import Foundation

import Prelude
import RestClient

public struct Jira {
    private let client: JiraClient

    public init(serverHost: URL, credentials: JiraServerCredentials) throws {
        client = try JiraClient.jiraServerClient(host: serverHost, credentials: credentials)
    }

    public init(serverHost: URL, authorizer: JiraAuthorizer) {
        client = JiraClient.jiraServerClient(host: serverHost, authorizer: authorizer)
    }

    public func currentUser() async throws -> User {
        let response = try await client.getCurrentUser()
        return User(response: response, client: client)
    }

    public func user(name: String) async throws -> User {
        let response = try await client.getUser(username: name)
        return User(response: response, client: client)
    }

    public func issue(key: String) async throws -> Issue {
        let response = try await client.getIssue(key: key)
        return IssueWithFields(response: response, client: client)
    }

    public func searchIssues(jql: JQLQuery) async throws -> PaginatingList<IssueWithFields<NoFields>> {
        try await searchIssues(jql: jql, fields: NoFields.self)
    }

    public func searchIssues<Fields: IssueFields>(jql: JQLQuery, fields: Fields.Type) async throws -> PaginatingList<IssueWithFields<Fields>> {
        PaginatingList { [client] page, pageSize in
            let defaultPageSize = 50
            let pagination = Pagination(page: page, pageSize: pageSize ?? defaultPageSize)
            let issuesResponse = try await client.getSearchResults(query: jql, pagination: pagination, fields: fields)
            let issues = issuesResponse.map { issueResponse in
                IssueWithFields(response: issueResponse, client: client)
            }
            return issues
        }
    }
}
