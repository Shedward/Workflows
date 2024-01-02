//
//  AllDependencies.swift
//
//
//  Created by Vlad Maltsev on 08.12.2023.
//

import Workflow
import HeadHunter

protocol AllDependencies {
    var workflowsStorage: WorkflowsStorage<PortfolioDependencies> { get }
    var newWorkflowsService: NewWorkflowService { get }
    var workflowTypeAppearance: WorkflowAppearanceService { get }
    var activeWorkflowService: ActiveWorkflowService { get }
}
