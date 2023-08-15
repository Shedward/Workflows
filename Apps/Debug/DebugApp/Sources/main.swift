// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import SecureStorage
import RestClient
import GitHub
import Jira
import Figma
import Executable
import Prelude
import os
import Git
import GoogleDrive
import GoogleSheets

let debugCredentials = DebugCredentials()

extension LoggerScope {
    static let demoApp = LoggerScope(name: "Demo App")
}

Logger.enabledScopes = [.network, .demoApp, .global]

let logger = Logger(scope: .demoApp)

func testGitHub() async throws {
    let github = GitHub(token: try debugCredentials.githubToken())
    let repo = try await github.repo(owner: "hhru", name: "ios-apps")

    let oldestPullRequests = try await repo
        .pullRequests(query: .init(state: .opened, sorting: .init(sortBy: .created, direction: .descending)))
        .allItems(maxCount: 5)

    print(oldestPullRequests)
}

func testJira() async throws {
    let jiraCreds = try debugCredentials.jiraCreds()
    let jira = try Jira(serverHost: URL(string: "https://jira.hh.ru")!, credentials: jiraCreds)

    let query = JQLQuery(rawValue: "assignee = currentUser() AND type = Проект")
    let myIssues = try await jira.searchIssues(jql: query).allItems()

    print(myIssues)
}

func testGit() async throws {
    let git = Git()
    let workflowsRepository = try await git.repository(at: "/Users/shed/Projects/Workflows")
    let branch = try await workflowsRepository.currentBranch()

    print(branch)
}

func testCurrentIssue() async throws {
    let git = Git()
    let analyticsRepo = try await git.repository(at: "/Users/shed/Projects/hh-mobile-analytics")
    let workingBranch = try await analyticsRepo.currentBranch()

    let jiraCreds = try debugCredentials.jiraCreds()
    let jira = try Jira(serverHost: URL(string: "https://jira.hh.ru")!, credentials: jiraCreds)
    let workingIssue = try await jira.issue(key: workingBranch.rawValue)

    print("Current analytics about \(workingIssue)")
}

func testFigma() async throws {
    let figma = Figma(token: try debugCredentials.figmaToken())
    let me = try await figma.me()

    print("Current user \(me)")

    let magrittoFile = figma.file(key: "iKAlkRsX1xUEKc0DVpQ4A8")
    let magrittoComments = try await magrittoFile.comments()

    print("Comments: \n \(magrittoComments)")
}

func testGoogleDrive() async throws {
    let googleDrive = GoogleDrive(accessToken: try debugCredentials.googleAccessToken())
    let newFile = try await googleDrive.createFile(.init(name: "TestText", mimeType: "text/plain"))
    print(newFile)
}

func testGoogleSheets() async throws {
    let googleSheets = GoogleSheets(key: try debugCredentials.googleKey())
    let newSpreadsheet = try await googleSheets.createSpreadsheet(.init(title: "TestSheets"))
    print(newSpreadsheet)
}

try await testGoogleSheets()