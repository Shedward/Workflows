//
//  PortfolioState+Delete.swift
//  
//
//  Created by Vlad Maltsev on 12.12.2023.
//

import Workflow
import Prelude

extension PortfolioState {
    struct Delete: Transition {
        
        let id = "Portfolio.Delete"
        let name = "Удалить"
        
        var steps: TransitionSteps<PortfolioState> {
            .init { workflow, _ in
                try await workflow.delete()
            }
        }
    }
}
