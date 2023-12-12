//
//  WorkflowTests.swift
//  
//
//  Created by Vlad Maltsev on 04.12.2023.
//

@testable import Workflow
import XCTest
import LocalStorage

final class WorkflowTests: XCTestCase {
    
    func testBasicUsage() async throws {
        let storage = InMemoryCodableStorage()
        let initialState = TaskState.todo(.init(id: "mock"))
        let details = WorkflowDetails(
            id: WorkflowId(rawValue: "mock"),
            type: WorkflowType(TaskState.self),
            key: "mock"
        )
        let workflow = try Workflow.create(
            details: details,
            initialState: initialState,
            storage: storage,
            dependencies: ()
        )
        
        let currentState = workflow.state.description
        XCTAssertEqual(currentState.id, "ToDo")
        
        let transitions = workflow.transitions
        XCTAssertEqual(transitions.count, 1)
        
        let startTask = try XCTUnwrap(transitions.first(id: "StartTask"))
        try await startTask()
        
        let currentState2 = workflow.state.description
        XCTAssertEqual(currentState2.id, "InProgress")
        
        let transitions2 = workflow.transitions
        let startReview = try XCTUnwrap(transitions2.first(id: "SendToReview"))
        try await startReview()
        
        let currentState3 = workflow.state.description
        XCTAssertEqual(currentState3.id, "Review")
        
        let loadedWorkflow = try Workflow<TaskState>.load(storage: storage, dependencies: ())
        let currentState4 = loadedWorkflow.state.description
        XCTAssertEqual(currentState4.id, "Review")
    }
}
