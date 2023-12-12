//
//  StartTesting.swift
//
//
//  Created by Vlad Maltsev on 04.12.2023.
//

import Workflow

extension TaskState {

    struct StartTesting: Transition {
        
        let review: Review
        
        let id = "StartTesting"
        let name = "Начать тестирование"
        
        func callAsFunction(_ workflow: Workflow<TaskState>) async throws {
            try workflow.move(
                to: .testing(TaskState.Testing(id: review.id, tester: "some@tester"))
            )
        }
    }
}
