//
//  PullRequestTests.swift
//
//
//  Created by v.maltsev on 23.09.2023.
//

@testable import GitHub
import XCTest

final class PullRequestTests: XCTestCase {
    func testGetPullRequests() async throws {

        let mock = GitHubMock()
        let github = GitHub(mock: mock)

        await mock.setPullRequestsResponse(
            owner: "MockOwner",
            repoName: "MockRepo",
            response: [
                .init(id: 1, title: "Mock Pull Request To Mock Repo")
            ]
        )

        let repo = github.repo(owner: "MockOwner", name: "MockRepo")
        let allPullRequests = try await repo.pullRequests().allItems()

        XCTAssertEqual(allPullRequests.count, 1)
        let firstPullRequest = try XCTUnwrap(allPullRequests.first)
        XCTAssertEqual(firstPullRequest.title, "Mock Pull Request To Mock Repo")

        await mock.setPullRequestsResponse(
            owner: "MockOwner",
            repoName: "MockRepo",
            forQuery: .init(state: .closed),
            response: [
                .init(id: 2, title: "First closed mock pull request"),
                .init(id: 3, title: "Second closed mock pull request")
            ]
        )

        let closedPullRequests = try await repo.pullRequests(query: .init(state: .closed)).allItems()
        XCTAssertEqual(closedPullRequests.count, 2)
        let firstClosedPullRequest = try XCTUnwrap(closedPullRequests.first)
        XCTAssertEqual(firstClosedPullRequest.title, "First closed mock pull request")
    }
}
