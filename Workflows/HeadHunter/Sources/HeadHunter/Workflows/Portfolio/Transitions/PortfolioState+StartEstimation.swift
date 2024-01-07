//
//  PortfolioState+StartEstimation.swift
//
//
//  Created by Vlad Maltsev on 06.12.2023.
//

import Workflow
import Prelude

extension PortfolioState {
    struct StartEstimation: Transition {
        
        let id = "Portfolio.StartEstimation"
        let name = "Декомпозировать"
        
        let todo: PortfolioState.ToDo
        
        var steps: TransitionSteps<PortfolioState> {
            .init { workflow, _ in
                let decompositionUrl = "https://sheet.google.com/\(todo.taskId)"
                try workflow.move(
                    to: .estimation(.init(taskId: todo.taskId, decompositionUrl: decompositionUrl))
                )
            }
        }
    }
}
