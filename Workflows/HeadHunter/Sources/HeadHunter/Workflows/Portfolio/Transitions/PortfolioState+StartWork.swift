//
//  PortfolioState+StartWork.swift
//
//
//  Created by Vlad Maltsev on 06.12.2023.
//

import Workflow
import Prelude

extension PortfolioState {
    struct StartWork: Transition {
        
        let id = "Portfolio.StartWork"
        let name = "Завершить декомпозицию"
        
        let estimation: PortfolioState.Estimation
        
        var steps: TransitionSteps<PortfolioState> {
            .init { workflow, _ in
                try workflow.move(to: .inProgress(.init(taskId: estimation.taskId, branchName: estimation.taskId)))
            }
        }
    }
}
