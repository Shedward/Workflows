//
//  PortfolioFinishEstimation.swift
//
//
//  Created by Vlad Maltsev on 06.12.2023.
//

import Workflow

extension PortfolioState {
    struct FinishEstimation: Transition {
        
        let id = "Portfolio.FinishEstimation"
        let name = "Завершить декомпозицию"
        
        let estimation: PortfolioState.Estimation
        
        func callAsFunction(_ workflow: Workflow<PortfolioState>) async throws {
            try workflow.move(to: .inProgress(.init(taskId: estimation.taskId, branchName: estimation.taskId)))
        }
    }
}
