//
//  RepoTests.swift
//  
//
//  Created by v.maltsev on 23.09.2023.
//

@testable import GitHub
import XCTest

final class RepoTests: XCTestCase {
    func testGetRepo() async throws {
        let mock = GitHubMock()
        let github = GitHub(mock: mock)

        await mock.setRepo(
            owner: "mockOwner",
            name: "Mock Repo",
            repo: RepoResponse(id: 1, owner: "mockOwner", name: "Mock Repo", description: "mock description")
        )
        let repo = github.repo(owner: "mockOwner", name: "Mock Repo")
        XCTAssertEqual(repo.name, "Mock Repo")
        let repoDetails = try await repo.details()
        XCTAssertEqual(repoDetails.name, "Mock Repo")
        XCTAssertEqual(repoDetails.description, "mock description")
    }
}

