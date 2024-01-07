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
        
        var steps: TransitionSteps<TaskState> {
            .init { workflow, _ in
                try workflow.move(
                    to: .testing(TaskState.Testing(id: review.id, tester: "some@tester"))
                )
            }
        }
    }
}
