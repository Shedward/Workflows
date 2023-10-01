//
//  RepositoryTests.swift
//
//
//  Created by Vlad Maltsev on 01.10.2023.
//

@testable import Git
import TestsPrelude
import XCTest

final class RepositoryTests: XCTestCase {
    func testCurrentBranch() async throws {
        let mock = GitMock()
        let git = Git(mock: mock)
        
        await mock.addRepository(workingDirectory: "/mock/path", result: .success(()))
        await mock.addCurrentBranch(workingDirectory: "/mock/path", ref: .success("mock_branch"))
        
        let repository = try await git.repository(at: "/mock/path")
        let currentBranch = try await repository.currentBranch()
        XCTAssertEqual(currentBranch.rawValue, "mock_branch")
    }
    
    func testCurrentBranchFailed() async throws {
        let mock = GitMock()
        let git = Git(mock: mock)
        
        await mock.addRepository(workingDirectory: "/mock/path", result: .success(()))
        await mock.addCurrentBranch(workingDirectory: "/mock/path", ref: .failure(MockFailure("Branch is not specified")))
        
        let repository = try await git.repository(at: "/mock/path")
        
        
        await XCTExpectAsyncThrow(MockFailure("Branch is not specified")) {
            _ = try await repository.currentBranch()
        }
    }
}
