//
//  GitHubUserTests.swift
//
//
//  Created by v.maltsev on 23.09.2023.
//

@testable import GitHub
import XCTest

final class UserTests: XCTestCase {
    func testGetUser() async throws {
        let mock = GitHubMock()
        let github = GitHub(mock: mock)

        await mock.setCurrentUser(UserResponse(id: 1, login: "mock", name: "Mock"))
        let currentUser = try await github.currentUser()
        XCTAssertEqual(currentUser.name, "Mock")
    }
}
