//
//  Mocks+PortfolioWorkflow.swift
//
//
//  Created by Vlad Maltsev on 10.12.2023.
//

import Workflow
import LocalStorage

extension Mocks {
    public static func portfolioWorkflow(name: String = "Mock portfolio") -> Workflow<PortfolioState> {
        try! Workflow.create(
            details: WorkflowDetails(
                id: WorkflowId(rawValue: "mock.portfolioWorkflow"),
                type: WorkflowType(PortfolioState.self),
                key: "PORTFOLIO-11063",
                name: name
            ),
            initialState: PortfolioState.toDo(.init(taskId: "PORTFOLIO-mock")),
            storage: .mock,
            dependencies: ()
        )
    }
}
