//
//  Jira.swift
//  Created by Vladislav Maltsev on 26.07.2023.
//

import Foundation

import Prelude
import RestClient

public struct Jira {
    internal let client: JiraClient

    public init(serverHost: URL, credentials: JiraServerCredentials) throws {
        client = try JiraClient.jiraServerClient(host: serverHost, credentials: credentials)
    }

    public init(serverHost: URL, authorizer: JiraAuthorizer) {
        client = JiraClient.jiraServerClient(host: serverHost, authorizer: authorizer)
    }
    
    public init(mock: JiraMock) {
        client = JiraClient.mock(mock)
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
        try await issue(key: key, fields: NoFields.self)
    }

    public func issue<Fields: IssueFields>(key: String, fields: Fields.Type) async throws -> IssueWithFields<Fields> {
        let response = try await client.getIssue(key: key, fields: Fields.self)
        return IssueWithFields(response: response, client: client)
    }

    public func searchIssues(jql: JQLQuery) async throws -> PaginatingList<Issue> {
        searchIssues(jql: jql, fields: NoFields.self)
    }

    public func searchIssues<Fields: IssueFields>(jql: JQLQuery, fields: Fields.Type) -> PaginatingList<IssueWithFields<Fields>> {
        let defaultPageSize: Int = 50
        return PaginatingList(pageSize: defaultPageSize) { [client] page, pageSize in
            let pagination = Pagination(page: page, pageSize: pageSize ?? defaultPageSize)
            let issuesResponse = try await client.getSearchResults(query: jql, pagination: pagination, fields: fields)
            let issues = issuesResponse.map { issueResponse in
                IssueWithFields(response: issueResponse, client: client)
            }
            return issues
        }
    }
}
