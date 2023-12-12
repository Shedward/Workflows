//
//  PortfolioBackToToDo.swift
//
//
//  Created by Vlad Maltsev on 06.12.2023.
//

import Workflow

extension PortfolioState {
    struct BackToToDo: Transition {
        
        let id = "Portfolio.BackToToDo"
        let name = "Вернуть в Сделать"
        
        let taskId: String
        
        func callAsFunction(_ stateMachine: StateMachine<PortfolioState>) async throws {
            try stateMachine.move(to: .toDo(.init(taskId: taskId)))
        }
    }
}
