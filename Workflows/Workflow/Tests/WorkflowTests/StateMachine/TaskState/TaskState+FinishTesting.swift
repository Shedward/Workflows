//
//  TaskState+FinishTesting.swift
//  
//
//  Created by Vlad Maltsev on 04.12.2023.
//

import Workflow

extension TaskState {

    struct FinishTesting: Transition {
        
        let testing: Testing
        
        let id = "StartTesting"
        let name = "Начать тестирование"
        
        func callAsFunction(_ workflow: Workflow<TaskState>) async throws {
            try workflow.move(
                to: .done(TaskState.Done(id: testing.id))
            )
        }
    }
}
