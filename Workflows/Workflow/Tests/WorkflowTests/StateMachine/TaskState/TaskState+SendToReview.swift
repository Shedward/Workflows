//
//  TaskState+SendToReview.swift
//
//
//  Created by Vlad Maltsev on 03.12.2023.
//

import Workflow

extension TaskState {

    struct SendToReview: Transition {
        
        let inProgress: InProgress
        
        let id = "SendToReview"
        let name = "Отправить на ревью"
        
        var steps: TransitionSteps<TaskState> {
            .init { workflow, _ in
                try workflow.move(
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
}
