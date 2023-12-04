//
//  StartTesting.swift
//
//
//  Created by Vlad Maltsev on 04.12.2023.
//

import Workflows

extension TaskState {

    struct StartTesting: Transition {
        
        let review: Review
        
        let id = "StartTesting"
        let name = "Начать тестирование"
        
        func callAsFunction(_ stateMachine: StateMachine<TaskState>) async throws {
            try await stateMachine.move(
                to: .testing(TaskState.Testing(id: review.id, tester: "some@tester"))
            )
        }
    }
}
