//
//  GetCurrentTaskTests.swift
//
//
//  Created by Vlad Maltsev on 01.10.2023.
//

@testable import HeadHunter
@testable import Git
@testable import Jira
import XCTest

final class GetCurrentTaskTests: XCTestCase {
    func testSuccessfullFlow() async throws {
        let mocks = Mocks()
        let dependencies = MockDependencies(mocks: mocks)
        
        await mocks.git.addRepository(workingDirectory: "mock/repository/path", result: .success(()))
        await mocks.git.addCurrentBranch(workingDirectory: "mock/repository/path", ref: .success("MOCK_TASK"))
        await mocks.jira.addGetIssueResponse(
            key: "MOCK_TASK",
            fields: TaskIssueFields.self,
            response: .success(
                IssueDetails<TaskIssueFields>(
                    id: "1",
                    key: "MOCK_TASK",
                    fields: .init(
                        summary: "Mock task title",
                        issuelinks: [],
                        status: .init(id: "1", name: "Status", iconUrl: nil, description: nil),
                        issuetype: .init(id: "1", name: "Type", description: "Description", iconUrl: nil, subtask: false),
                        priority: .init(id: "1", name: "Priority", iconUrl: nil)
                    )
                )
            )
        )
        
        let config = MainRepositoryConfig(repositoryPath: "mock/repository/path")
        
        let action = GetCurrentTask(deps: dependencies, mainRepoConfig: config)
        let output = try await action.perform()
        
        XCTAssertEqual(output.task.key, "MOCK_TASK")
        XCTAssertEqual(output.task.title, "Mock task title")
    }
}
