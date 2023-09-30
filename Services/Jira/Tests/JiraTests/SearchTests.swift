//
//  SearchTests.swift
//
//
//  Created by Vlad Maltsev on 30.09.2023.
//

@testable import Jira
import XCTest
import TestsPrelude

import Prelude
import os

final class SearchTests: XCTestCase {
    func testSearch() async throws {
        let mock = JiraMock()
        let jira = Jira(mock: mock)
        
        await mock.setGetSearchResultsResponse(
            query: "assignee = mock.user",
            fields: NoFields.self,
            response: .success([
                .init(id: "1", key: "MOCK-1", fields: NoFields()),
                .init(id: "2", key: "MOCK-2", fields: NoFields())
            ])
        )
        
        let results = try await jira.searchIssues(jql: "assignee = mock.user").allItems()
        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results.first?.key, "MOCK-1")
    }
    
    func testSearchFailure() async throws {
        let mock = JiraMock()
        let jira = Jira(mock: mock)
        
        await mock.setGetSearchResultsResponse(
            query: "assignee = mock.user",
            fields: NoFields.self,
            response: .failure(MockFailure("Failed request"))
        )
        
        await XCTExpectAsyncThrow(MockFailure("Failed request")) {
            _ = try await jira.searchIssues(jql: "assignee = mock.user").allItems()
        }
    }
}
