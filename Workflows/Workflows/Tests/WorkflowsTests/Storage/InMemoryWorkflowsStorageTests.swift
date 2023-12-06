//
//  InMemoryWorkflowsStorageTests.swift
//
//
//  Created by Vlad Maltsev on 23.10.2023.
//

@testable import Workflows
import XCTest

final class InMemoryWorkflowsStorageTests: XCTestCase {
    private var storage: InMemoryWorkflowsStorage!
    
    override func setUp() async throws {
        storage = InMemoryWorkflowsStorage()
    }
    
    override func tearDown() async throws {
        storage = nil
    }
    
    func testEmptyWorkflowStorage() async throws {
        let workflows = try await storage.workflows()
        XCTAssertEqual(workflows.count, 0)
    }
    
    func testCreatingAndReading() async throws {
        let w1 = try await storage.startWorkflow(name: "w1", initialState: TaskState.todo(.init(id: "w1")))
        let w2 = try await storage.startWorkflow(name: "w2", initialState: TaskState.todo(.init(id: "w2")))
        let _ = try await storage.startWorkflow(name: "w3", initialState: TaskState.todo(.init(id: "w3")))
        
        let workflows = try await storage.workflows()
        XCTAssertEqual(workflows.count, 3)
        
        let reopenW2 = try await storage.workflow(w2.details.id)
        XCTAssertEqual(w2.details, reopenW2.details)
        
        try await storage.stopWorkflow(w1.details.id)
        let workflowsAfterStop = try await storage.workflows()
        XCTAssertEqual(workflowsAfterStop.count, 2)
        
    }
    
    func testWorkflowStorage() async throws {
        let workflow = try await storage.startWorkflow(
            name: "directory tests workflow",
            initialState: TaskState.todo(.init(id: "directory"))
        )
        try workflow.storage.save("Hello workflow", at: "test")
        let savedData: String = try workflow.storage.load(at: "test")
        XCTAssertEqual(savedData, "Hello workflow")
    }
}
