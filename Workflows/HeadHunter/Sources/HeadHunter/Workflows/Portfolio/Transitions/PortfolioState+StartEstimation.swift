//
//  PortfolioStartEstimation.swift
//
//
//  Created by Vlad Maltsev on 06.12.2023.
//

import Workflow

extension PortfolioState {
    struct StartEstimation: Transition {
        
        let id = "Portfolio.StartEstimation"
        let name = "Декомпозировать"
        
        let todo: PortfolioState.ToDo
        
        func callAsFunction(_ stateMachine: StateMachine<PortfolioState>) async throws {
            let decompositionUrl = "https://sheet.google.com/\(todo.taskId)"
            try stateMachine.move(
                to: .estimation(.init(taskId: todo.taskId, decompositionUrl: decompositionUrl))
            )
        }
    }
}
