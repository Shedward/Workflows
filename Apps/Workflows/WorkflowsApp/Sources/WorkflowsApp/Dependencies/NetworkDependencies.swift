//
//  NetworkDependencies.swift
//
//
//  Created by Vlad Maltsev on 08.12.2023.
//

import Workflow
import HeadHunter
import FileSystem

struct NetworkDependencies: AllDependencies {
    
    let workflowsStorage: WorkflowsStorage<Void>
    let newWorkflowsService: NewWorkflowService
    
    init() {
        let workflowsLoader = DynamicWorkflowLoader {
            WorkflowLoader(PortfolioState.self)
        }
        
        let filesystem = FileManagerFileSystem()
        let workflowsRoot = filesystem.homeDirectory().appending("workflows")
        
        let workflowsStorage = WorkflowsStorage(
            at: workflowsRoot,
            dynamicLoader: workflowsLoader,
            dependencies: ()
        )

        let newWorkflowsService = NewWorkflowService {
            NewPortfolioWorkflowProvider(storage: workflowsStorage)
        }
        
        self.workflowsStorage = workflowsStorage
        self.newWorkflowsService = newWorkflowsService
    }
}
