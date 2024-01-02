//
//  PortfolioState+Delete.swift
//  
//
//  Created by Vlad Maltsev on 12.12.2023.
//

import Workflow

extension PortfolioState {
    struct Delete: Transition {
        
        let id = "Portfolio.Delete"
        let name = "Удалить"
        
        func callAsFunction(_ workflow: Workflow<PortfolioState>) async throws {
            try await workflow.delete()
        }
    }
}
