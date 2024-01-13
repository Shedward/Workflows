//
//  PortfolioState+BackToToDo.swift
//
//
//  Created by Vlad Maltsev on 06.12.2023.
//

import Workflow
import Prelude

extension PortfolioState {
    struct BackToToDo: Transition {

        let id = "Portfolio.BackToToDo"
        let name = "Вернуть в Сделать"
        
        let taskId: String
        
        var steps: TransitionSteps<PortfolioState> {
            .init { ctx, _ in
                try ctx.workflow.move(to: .toDo(.init(taskId: taskId)))
            }
        }
    }
}
