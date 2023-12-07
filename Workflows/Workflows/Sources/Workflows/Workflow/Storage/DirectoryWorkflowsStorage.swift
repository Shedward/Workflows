//
//  DirectoryWorkflowsStorage.swift
//
//
//  Created by Vlad Maltsev on 07.10.2023.
//

import LocalStorage
import FileSystem
import Prelude
import Foundation

public class WorkflowsStorage<Dependencies> {

    private let rootItem: FileItem
    private let dynamicLoader: DynamicWorkflowLoader
    private let dependencies: Dependencies
    private let formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        return formatter
    }()
    
    public var configs: CodableStorage {
        DirectoryCodableStorage(at: rootItem.appending(".config"))
    }
    
    public var sharedCache: WorkflowsCache {
        WorkflowsCache()
    }
    
    public init(at rootItem: FileItem, dynamicLoader: DynamicWorkflowLoader, dependencies: Dependencies) {
        self.rootItem = rootItem
        self.dynamicLoader = dynamicLoader
        self.dependencies = dependencies
    }
    
    public func workflows() async throws -> [AnyWorkflow] {
        try await Task(priority: .userInitiated) { () -> [AnyWorkflow] in
            let childs = try Failure.wrap("Extracting content of \(rootItem)") {
                try rootItem.childs()
            }
            
            let workflows = try childs.compactMap { possibleWorkflowItem -> AnyWorkflow? in
                let id = WorkflowId(rawValue: possibleWorkflowItem.name)
                let possibleWorkflowStorage = DirectoryCodableStorage(at: possibleWorkflowItem)
                
                guard possibleWorkflowStorage.exists(at: WorkflowKeys.workflow) else {
                    return nil
                }
                
                return try loadWorkflow(id: id)
            }
            return workflows
        }.value
    }
    
    public func workflow(_ id: WorkflowId) async throws -> AnyWorkflow {
        try await Task(priority: .userInitiated) { () -> AnyWorkflow in
            try loadWorkflow(id: id)
        }.value
    }
    
    public func startWorkflow<S>(
        name: String,
        initialState: S
    ) async throws -> AnyWorkflow where S: State, S.Dependencies == Dependencies {
        try await Task(priority: .userInitiated) { () -> AnyWorkflow in
            let id = try firstFreeWorkflowId(name: name)
            
            let workflowItem = self.workflowItem(id: id)
            try Failure.wrap("Creating workflow directory at \(workflowItem)") {
                try workflowItem.createDirectory()
            }
            
            let storage = DirectoryCodableStorage(at: workflowItem)
            let details = WorkflowDetails(id: id, type: WorkflowType(S.self), name: name)
            
            let workflow = try Failure.wrap("Creating workflow config at \(details)") {
                try Workflow.create(details: details, initialState: initialState, storage: storage, dependencies: self.dependencies)
            }
            
            return workflow.asAny()
        }.value
    }
    
    public func stopWorkflow(_ id: WorkflowId) async throws {
        try await Task(priority: .userInitiated) {
            try workflowItem(id: id).delete()
        }.value
    }

    private func loadWorkflow(id: WorkflowId) throws -> AnyWorkflow {
        let storage = DirectoryCodableStorage(at: workflowItem(id: id))
        let details = try storage.load(WorkflowDetails.self, at: WorkflowKeys.workflow)
        let workflow = try dynamicLoader.load(details: details, from: storage, dependencies: dependencies)
        return workflow
    }
    
    private func workflowItem(id: WorkflowId) -> FileItem {
        rootItem.appending(id.rawValue + "/")
    }
    
    private func firstFreeWorkflowId(name: String, maxRetries: Int = 10) throws -> WorkflowId {
        let timestamp = formatter.string(from: Date())
        for index in 0..<maxRetries {
            let id = WorkflowId(name: name, suffix: "\(timestamp)-\(index)")
            
            if !workflowItem(id: id).isExists {
                return id
            }
        }
        
        throw Failure("Not found free folder for \(name) after \(maxRetries) tries, clean workflows folder or increase limit")
    }
}
