// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import SecureStorage
import RestClient
import GitHub
import Jira
import Executable
import Prelude
import os

let debugCredentials = DebugCredentials()

extension LoggerScope {
    static let demoApp = LoggerScope(name: "Demo App")
}

Logger.enabledScopes = [.network, .demoApp]

let logger = Logger(scope: .demoApp)

func testGitHub() async throws {
    let github = GitHub(token: try debugCredentials.githubToken())
    let repo = try await github.repo(owner: "hhru", name: "ios-apps")
    let pullRequests = try await repo.pullRequests().withPageSize(5).allItems()

    print(pullRequests.count)
    print(pullRequests)
}

func testJira() async throws {
    let jiraCreds = try debugCredentials.jiraCreds()
    let jira = try Jira(serverHost: URL(string: "https://jira.hh.ru")!, credentials: jiraCreds)

    let query = JQLQuery(rawValue: "assignee = currentUser() AD type = Проект")
    let myIssues = try await jira.searchIssues(jql: query).allItems()

    print(myIssues)
}

func testExecutable() async throws {
    let lsExecutable = Executable(filePath: "/bin/ls")
    try await lsExecutable.run(["-l", "-a"])
}

try await testExecutable()
