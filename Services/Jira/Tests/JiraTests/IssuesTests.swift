//
//  IssuesTests.swift
//
//
//  Created by Vlad Maltsev on 30.09.2023.
//

@testable import Jira
import XCTest

final class IssuesTests: XCTestCase {
    func testGetIssue() async throws {
        let mock = JiraMock()
        let jira = Jira(mock: mock)
        
        await mock.setGetIssueResponse(
            key: "mock-1",
            fields: NoFields.self,
            response: .success(IssueDetails<NoFields>(id: "1", key: "mock-1", fields: NoFields()))
        )
        
        let issue = try await jira.issue(key: "mock-1")
        XCTAssertEqual(issue.key, issue.key)
    }
}
