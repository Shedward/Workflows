//
//  RepoTests.swift
//  
//
//  Created by v.maltsev on 23.09.2023.
//

@testable import GitHub
import XCTest
import TestsPrelude

final class RepoTests: XCTestCase {
    func testGetRepo() async throws {
        let mock = GitHubMock()
        let github = GitHub(mock: mock)

        await mock.setRepoResponse(
            owner: "mockOwner",
            name: "Mock Repo",
            response: .success(
                RepoResponse(id: 1, owner: "mockOwner", name: "Mock Repo", description: "mock description")
            )
        )
        let repo = github.repo(owner: "mockOwner", name: "Mock Repo")
        XCTAssertEqual(repo.name, "Mock Repo")
        let repoDetails = try await repo.details()
        XCTAssertEqual(repoDetails.name, "Mock Repo")
        XCTAssertEqual(repoDetails.description, "mock description")

        await mock.setRepoResponse(
            owner: "mockOwner",
            name: "Mock Repo",
            response: .failure(MockFailure("Failed request"))
        )

        await XCTExpectAsyncThrow(MockFailure("Failed request")) {
            _ = try await repo.details()
        }
    }
}

