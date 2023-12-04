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

public class DirectoryWorkflowsStorage: WorkflowsStorage {

    private let rootItem: FileItem
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
    
    public init(at rootItem: FileItem) {
        self.rootItem = rootItem
    }
    
    public func workflows() async throws -> [Workflow] {
        try await Task(priority: .userInitiated) { () -> [Workflow] in
            let childs = try Failure.wrap("Extracting content of \(rootItem)") {
                try rootItem.childs()
            }
            
            let workflows = try childs.compactMap { possibleWorkflowItem -> Workflow? in
                let id = WorkflowId(rawValue: possibleWorkflowItem.name)
                
                let workflowConfig = self.workflowConfig(id: id)
                guard workflowConfig.isExists else {
                    return nil
                }
                return try loadWorkflow(id: id)
            }
            return workflows
        }.value
    }
    
    public func workflow(_ id: WorkflowId) async throws -> Workflow {
        try await Task(priority: .userInitiated) { () -> Workflow in
            try loadWorkflow(id: id)
        }.value
    }
    
    public func startWorkflow(name: String) async throws -> Workflow {
        try await Task(priority: .userInitiated) { () -> Workflow in
            let id = try firstFreeWorkflowId(name: name)
            
            let workflowItem = self.workflowItem(id: id)
            try Failure.wrap("Creating workflow directory at \(workflowItem)") {
                try workflowItem.createDirectory()
            }
            
            let workflowDetails = WorkflowDetails(id: id, name: name)
            let workflowConfig = self.workflowConfig(id: id)
            try Failure.wrap("Creating workflow config at \(workflowConfig)") {
                try workflowConfig.save(workflowDetails)
            }
            
            return Workflow(
                details: workflowDetails,
                storage: DirectoryCodableStorage(at: workflowItem)
            )
        }.value
    }
    
    public func stopWorkflow(_ id: WorkflowId) async throws {
        try await Task(priority: .userInitiated) {
            try workflowItem(id: id).delete()
        }.value
    }
    
    private func loadWorkflow(id: WorkflowId) throws -> Workflow {
        let workflowConfig = self.workflowConfig(id: id)
        let workflowDetails: WorkflowDetails = try Failure.wrap(
            "Reading workflow config at \(workflowConfig)"
        ) {
            try workflowConfig.load()
        }
        
        return Workflow(
            details: workflowDetails,
            storage: DirectoryCodableStorage(at: workflowItem(id: id))
        )
    }
    
    private func workflowItem(id: WorkflowId) -> FileItem {
        rootItem.appending(id.rawValue + "/")
    }
    
    private func workflowConfig(id: WorkflowId) -> FileItem {
        workflowItem(id: id).appending("workflow.json")
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
