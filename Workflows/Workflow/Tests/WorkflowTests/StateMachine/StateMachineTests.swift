//
//  StateMachineTests.swift
//  
//
//  Created by Vlad Maltsev on 04.12.2023.
//

@testable import Workflow
import XCTest
import LocalStorage

final class StateMachineTests: XCTestCase {
    
    func testBasicUsage() async throws {
        let storage = InMemoryCodableStorage()
        let initialState = TaskState.todo(.init(id: "mock"))
        let stateMachine = StateMachine(initialState: initialState, storage: storage.accessor(for: "task"), dependencies: ())
        
        let currentState = stateMachine.state.description
        XCTAssertEqual(currentState.id, "ToDo")
        
        let transitions = stateMachine.transitions
        XCTAssertEqual(transitions.count, 1)
        
        let startTask = try XCTUnwrap(transitions.first(id: "StartTask"))
        try await startTask()
        
        let currentState2 = stateMachine.state.description
        XCTAssertEqual(currentState2.id, "InProgress")
        
        let transitions2 = stateMachine.transitions
        let startReview = try XCTUnwrap(transitions2.first(id: "SendToReview"))
        try await startReview()
        
        let currentState3 = stateMachine.state.description
        XCTAssertEqual(currentState3.id, "Review")
        
        let anotherStateMachine = try StateMachine<TaskState>(storage: storage.accessor(for: "task"), dependencies: ())
        let currentState4 = anotherStateMachine.state.description
        XCTAssertEqual(currentState4.id, "Review")
    }
}
