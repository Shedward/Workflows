//
//  NetworkDependencies.swift
//
//
//  Created by Vlad Maltsev on 08.12.2023.
//

import Workflow
import HeadHunter
import FileSystem

import SwiftUI

struct NetworkDependencies: AllDependencies {
    
    let workflowsStorage: WorkflowsStorage<PortfolioDependencies>
    let newWorkflowsService: NewWorkflowService
    let workflowTypeAppearance: WorkflowAppearanceService
    let activeWorkflowService: ActiveWorkflowService
    
    init() {
        let workflowsLoader = DynamicWorkflowLoader {
            WorkflowLoader(PortfolioState.self)
        }
        
        let workflowTypeAppearance = WorkflowAppearanceService(
            appearances: [
                WorkflowType(PortfolioState.self): WorkflowTypeAppearance(
                    icon: Image(systemName: "suitcase"),
                    name: "Портфель",
                    tintColor: \.accent
                )
            ]
        )
        
        let filesystem = FileManagerFileSystem()
        let workflowsRoot = filesystem.homeDirectory().appending("workflows")
        
        let dependencies: PortfolioDependencies = try! ActionPortfolioDependencies()
        let workflowsStorage = WorkflowsStorage(
            at: workflowsRoot,
            dynamicLoader: workflowsLoader,
            dependencies: dependencies
        )

        let newWorkflowsService = NewWorkflowService {
            NewPortfolioWorkflowProvider(storage: workflowsStorage, dependencies: dependencies)
        }
        
        self.workflowsStorage = workflowsStorage
        self.newWorkflowsService = newWorkflowsService
        self.workflowTypeAppearance = workflowTypeAppearance
        self.activeWorkflowService = ActiveWorkflowService()
    }
}
