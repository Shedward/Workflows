//
//  TaskState+FinishTesting.swift
//  
//
//  Created by Vlad Maltsev on 04.12.2023.
//

import Workflows

extension TaskState {

    struct FinishTesting: Transition {
        
        let testing: Testing
        
        let id = "StartTesting"
        let name = "Начать тестирование"
        
        func callAsFunction(_ stateMachine: StateMachine<TaskState>) async throws {
            try await stateMachine.move(
                to: .done(TaskState.Done(id: testing.id))
            )
        }
    }
}
