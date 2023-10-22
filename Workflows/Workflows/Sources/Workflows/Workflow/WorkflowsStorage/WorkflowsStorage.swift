//
//  WorkflowsStorage.swift
//
//
//  Created by Vlad Maltsev on 07.10.2023.
//

import LocalStorage

public protocol WorkflowsStorage {
    var configs: CodableStorage { get }
    var sharedCache: WorkflowsCache { get }
    
    func workflows() async throws -> [Workflow]
    func workflow(_ id: WorkflowId) async throws -> Workflow
    
    func startWorkflow(name: String) async throws -> Workflow
}
