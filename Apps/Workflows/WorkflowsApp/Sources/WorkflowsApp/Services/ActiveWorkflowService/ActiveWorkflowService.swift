//
//  ActiveWorkflowService.swift
//
//
//  Created by Vlad Maltsev on 11.12.2023.
//

import Workflow

final class ActiveWorkflowService {
    private var activeWorkflow: WorkflowId?
    
    init() {
    }
    
    func isActive(_ workflow: AnyWorkflow) -> Bool {
        workflow.id == activeWorkflow
    }
    
    func makeActive(_ workflow: AnyWorkflow) {
        activeWorkflow = workflow.id
    }
}
