//
//  DirectoryWorkflowsStorageTests.swift
//
//
//  Created by Vlad Maltsev on 23.10.2023.
//

@testable import Workflows
import FileSystem
import XCTest

final class DirectoryWorkflowsStorageTests: XCTestCase {
    private var workflowsStorage: DirectoryWorkflowsStorage!
    
    override func setUp() async throws {
        let fileSystem = InMemoryFileSystem()
        let loader = DynamicWorkflowLoader {
            WorkflowLoader(TaskState.self)
        }
        workflowsStorage = DirectoryWorkflowsStorage(at: fileSystem.rootItem, dynamicLoader: loader)
    }
    
    override func tearDown() async throws {
        workflowsStorage = nil
    }
    
    func testEmptyWorkflowStorage() async throws {
        let workflows = try await workflowsStorage.workflows()
        XCTAssertEqual(workflows.count, 0)
    }
    
    func testCreatingAndReading() async throws {
        let w1 = try await workflowsStorage.startWorkflow(name: "w1", initialState: TaskState.todo(TaskState.ToDo(id: "w1")))
        let w2 = try await workflowsStorage.startWorkflow(name: "w2", initialState: TaskState.todo(TaskState.ToDo(id: "w2")))
        let _ = try await workflowsStorage.startWorkflow(name: "w3", initialState: TaskState.todo(TaskState.ToDo(id: "w3")))
        
        let workflows = try await workflowsStorage.workflows()
        XCTAssertEqual(workflows.count, 3)
        
        let reopenW2 = try await workflowsStorage.workflow(w2.details.id)
        XCTAssertEqual(w2.details, reopenW2.details)
        
        try await workflowsStorage.stopWorkflow(w1.details.id)
        let workflowsAfterStop = try await workflowsStorage.workflows()
        XCTAssertEqual(workflowsAfterStop.count, 2)
    }
    
    func testWorkflowStorage() async throws {
        let workflow = try await workflowsStorage.startWorkflow(name: "directory tests workflow", initialState: TaskState.todo(TaskState.ToDo(id: "w1")))
        try workflow.storage.save("Hello workflow", at: "test")
        let savedData: String = try workflow.storage.load(at: "test")
        XCTAssertEqual(savedData, "Hello workflow")
    }
}
