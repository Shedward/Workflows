//
//  StateMachineTests.swift
//  
//
//  Created by Vlad Maltsev on 04.12.2023.
//

@testable import Workflows
import XCTest
import LocalStorage

final class StateMachineTests: XCTestCase {
    
    func testBasicUsage() async throws {
        let storage = InMemoryCodableStorage()
        let initialState = TaskState.todo(.init(id: "mock"))
        let stateMachine = StateMachine(initialState: initialState, storage: storage.accessor(for: "task"))
        
        let currentState = await stateMachine.state.description
        XCTAssertEqual(currentState.id, "ToDo")
        
        let transitions = await stateMachine.transitions
        XCTAssertEqual(transitions.count, 1)
        
        let startTask = try XCTUnwrap(transitions.first(id: "StartTask"))
        try await startTask()
        
        let currentState2 = await stateMachine.state.description
        XCTAssertEqual(currentState2.id, "InProgress")
        
        let transitions2 = await stateMachine.transitions
        let startReview = try XCTUnwrap(transitions2.first(id: "SendToReview"))
        try await startReview()
        
        let currentState3 = await stateMachine.state.description
        XCTAssertEqual(currentState3.id, "Review")
        
        let anotherStateMachine = try await StateMachine<TaskState>(storage: storage.accessor(for: "task"))
        let currentState4 = await anotherStateMachine.state.description
        XCTAssertEqual(currentState4.id, "Review")
    }
}
