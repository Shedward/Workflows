//
//  NewPortfoliosProvider.swift
//
//
//  Created by Vlad Maltsev on 07.12.2023.
//

import Foundation
import Workflow

public final class NewPortfolioWorkflowProvider: NewWorkflowProvider {

    public let id = "NewPortfolio"
    public let name = "Портфолио"
    
    let storage: WorkflowsStorage<PortfolioState.Dependencies>
    
    public init(storage: WorkflowsStorage<PortfolioState.Dependencies>) {
        self.storage = storage
    }
    
    public func workflows() async throws -> [AnyNewWorkflow] {
        return (1...10).map { id in
            let taskId = "PORTFOLIO-\(id)"
            let initialState = PortfolioState.toDo(.init(taskId: taskId))
            return NewWorkflow(
                description: .init(
                    id: taskId, 
                    key: taskId,
                    name: "Реализовать компонент \(id)",
                    type: WorkflowType(PortfolioState.self)
                ),
                initialState: initialState,
                storage: storage
            ).asAny()
        }
    }
}
