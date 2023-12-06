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
    
    func workflows() async throws -> [AnyWorkflow]
    func workflow(_ id: WorkflowId) async throws -> AnyWorkflow
    
    func startWorkflow<S: State>(name: String, initialState: S) async throws -> AnyWorkflow
    func stopWorkflow(_ workflow: WorkflowId) async throws
}
