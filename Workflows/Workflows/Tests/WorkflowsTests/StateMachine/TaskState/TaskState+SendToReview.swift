//
//  TaskState+SendToReview.swift
//
//
//  Created by Vlad Maltsev on 03.12.2023.
//

import Workflows

extension TaskState {

    struct SendToReview: Transition {
        
        let inProgress: InProgress
        
        let id = "SendToReview"
        let name = "Отправить на ревью"
        
        func callAsFunction(_ stateMachine: StateMachine<TaskState>) async throws {
            try await stateMachine.move(
                to: .review(
                    TaskState.Review(
                        id: inProgress.id,
                        branch: inProgress.branch,
                        reviewUrl: "https://github.com/\(inProgress.id)"
                    )
                )
            )
        }
    }
}
