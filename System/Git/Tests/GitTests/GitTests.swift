//
//  GitTests.swift
//
//
//  Created by Vlad Maltsev on 01.10.2023.
//

@testable import Git
import TestsPrelude
import XCTest

final class GitTests: XCTestCase {
    func testRepository() async throws {
        let mock = GitMock()
        let git = Git(mock: mock)
        
        await mock.addRepository(workingDirectory: "/Users/mock/Project", result: .success(()))
        
        let repository = try await git.repository(at: "/Users/mock/Project")
        XCTAssertEqual(repository.path, "/Users/mock/Project")
    }
    
    func testRepositoryNotFound() async throws {
        let mock = GitMock()
        let git = Git(mock: mock)
        
        await mock.addRepositoryNotFound(workingDirectory: "/Users/mock/Project")
        
        do {
            _ = try await git.repository(at: "/Users/mock/Project")
        } catch {
            switch error {
            case GitError.noGitRepositoryAtPath("/Users/mock/Project"):
                break
            default:
                XCTFail("Wrong error throwed")
            }
        }
    }
    
    func testRepositoryFailed() async throws {
        let mock = GitMock()
        let git = Git(mock: mock)
        
        await mock.addRepository(workingDirectory: "/Users/mock/Project", result: .failure(MockFailure("Git is not installed")))
        
        await XCTExpectAsyncThrow(MockFailure("Git is not installed")) {
            _ = try await git.repository(at: "/Users/mock/Project")
        }
    }
}
