//
//  AllDependencies.swift
//
//
//  Created by Vlad Maltsev on 08.12.2023.
//

import Workflow

protocol AllDependencies {
    var workflowsStorage: WorkflowsStorage<Void> { get }
    var newWorkflowsService: NewWorkflowService { get }
}
