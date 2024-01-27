//
//  NewPortfoliosProvider.swift
//
//
//  Created by Vlad Maltsev on 07.12.2023.
//

import Foundation
import Workflow
import Jira
import Prelude

public final class NewPortfolioWorkflowProvider: NewWorkflowProvider {

    public let id = "NewPortfolio"
    public let name = "Портфолио"
    
    private let storage: WorkflowsStorage<PortfolioState.Dependencies>
    private let dependencies: PortfolioState.Dependencies
    
    public init(storage: WorkflowsStorage<PortfolioState.Dependencies>, dependencies: PortfolioState.Dependencies) {
        self.storage = storage
        self.dependencies = dependencies
    }
    
    public func workflows() async throws -> [AnyNewWorkflow] {
        let query = try Failure.wrap("Loading filters from config") {
            let jiraConfig = try dependencies.configs.jira()
            return JQLQuery(rawValue: jiraConfig.filters.currentUserPortfolio)
        }
        
        let issues = try await Failure.wrap("Loading issues") {
            try await dependencies.jira.searchIssues(jql: query, fields: SummaryFields.self).allItems()
        }
        
        return issues.map { issue in
            NewWorkflow(
                description: .init(
                    id: issue.id,
                    key: issue.key,
                    name: issue.fileds.summary,
                    type: WorkflowType(PortfolioState.self)
                ),
                initialState: PortfolioState.toDo(.init(taskId: issue.key)),
                storage: storage
            )
            .asAny()
        }
    }
}
