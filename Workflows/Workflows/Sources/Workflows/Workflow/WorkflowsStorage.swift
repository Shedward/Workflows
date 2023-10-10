//
//  WorkflowsStorage.swift
//
//
//  Created by Vlad Maltsev on 07.10.2023.
//

import LocalStorage

public protocol WorkflowsStorage {
    var configs: ConfigStorage { get }
    var sharedCache: WorkflowsCache { get }
    
    func workflows() -> [Workflow]
    func startWorkflow(id: String) -> Workflow
}
