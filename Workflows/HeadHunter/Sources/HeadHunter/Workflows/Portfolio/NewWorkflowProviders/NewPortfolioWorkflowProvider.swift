//
//  NewPortfoliosProvider.swift
//
//
//  Created by Vlad Maltsev on 07.12.2023.
//

import Workflows

public final class NewPortfolioWorkflowProvider: NewWorkflowProvider {

    public let id = "NewPortfolio"
    public let name = "Портфолио"
    
    let storage: WorkflowsStorage<PortfolioState.Dependencies>
    
    public init(storage: WorkflowsStorage<PortfolioState.Dependencies>) {
        self.storage = storage
    }
    
    public func workflows() async throws -> [AnyNewWorkflow] {
        (1...10).map { id in
            let initialState = PortfolioState.toDo(.init(taskId: "PORTFOLIO-\(id)"))
            return NewWorkflow(initialState: initialState, storage: storage)
        }
    }
}
