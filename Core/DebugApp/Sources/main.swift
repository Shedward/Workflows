// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import SecureStorage
import RestClient
import GitHub
import Prelude

let debugCredentials = DebugCredentials()

func testGitHub() async throws {
    let github = GitHub(token: try debugCredentials.githubToken())
    let repo = try await github.repo(owner: "hhru", name: "ios-apps")
    let pullRequests = try await repo.pullRequests().allItems()

    print(pullRequests.count)
    print(pullRequests)
}

func testJira() async throws {
    let jiraToken = try debugCredentials.jiraCreds().token()
    let jiraRequest = RestRequest<EmptyBody, PlainTextBody>(
        method: .get,
        path: "/rest/api/2/user",
        query: RestQuery
            .set("username", to: "v.maltsev"),
        headers: RestHeaders
            .set("Authorization", to: "Basic \(jiraToken)")
            .set("Content-Type", to: "application/json")
    )

    let endpoint = RestEndpoint(host: URL(string: "https://jira.hh.ru")!)
    let client = RestClient(endpoint: endpoint)
    let response = try await client.request(jiraRequest)

    print(response)
}
