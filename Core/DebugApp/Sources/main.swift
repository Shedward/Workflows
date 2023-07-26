// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import SecureStorage
import RestClient
import GitHub
import Jira
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
    let jiraCreds = try debugCredentials.jiraCreds()
    let jira = try Jira(serverHost: URL(string: "https://jira.hh.ru")!, credentials: jiraCreds)
    let issue = try await jira.issue(key: "MOB-31553")

    print(issue)
}

try await testJira()
