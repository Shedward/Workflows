//
//  DirectoryWorkflowsStorage.swift
//
//
//  Created by Vlad Maltsev on 07.10.2023.
//

import LocalStorage
import Prelude
import Foundation

public class DirectoryWorkflowsStorage: WorkflowsStorage {

    private let directory: URL
    private let fileManager: FileManager
    private let formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        return formatter
    }()
    
    public var configs: CodableStorage {
        DirectoryCodableStorage(at: directory.appending(component: ".configs"))
    }
    
    public var sharedCache: WorkflowsCache {
        WorkflowsCache()
    }
    
    public init(directory: URL, fileManager: FileManager = .default) {
        self.directory = directory
        self.fileManager = fileManager
    }
    
    public func workflows() async throws -> [Workflow] {
        try await Task(priority: .userInitiated) { () -> [Workflow] in
            let content = try Failure.wrap("Extracting content of \(directory)") {
                try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: [], options: .skipsHiddenFiles)
            }
            
            let workflows = try content.compactMap { workflowPath -> Workflow? in
                let id = WorkflowId(rawValue: workflowPath.lastPathComponent)
                
                let workflowConfig = self.workflowConfig(id: id)
                guard fileManager.fileExists(atPath: workflowConfig.path()) else {
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
            
            let workflowPath = self.workflowPath(id: id)
            try Failure.wrap("Creating workflow directory at \(workflowPath)") {
                try fileManager.createDirectory(at: workflowPath, withIntermediateDirectories: true)
            }
            
            let workflowDetails = WorkflowDetails(id: id, name: name)
            let workflowConfig = self.workflowConfig(id: id)
            try Failure.wrap("Creating workflow config at \(workflowConfig)") {
                let data = try JSONEncoder().encode(workflowDetails)
                try data.write(to: workflowConfig)
            }
            
            return Workflow(
                details: workflowDetails,
                storage: DirectoryCodableStorage(at: workflowPath)
            )
        }.value
    }
    
    public func stopWorkflow(_ id: WorkflowId) async throws {
        try await Task(priority: .userInitiated) {
            try fileManager.removeItem(at: workflowPath(id: id))
        }.value
    }
    
    private func loadWorkflow(id: WorkflowId) throws -> Workflow {
        let workflowConfig = self.workflowConfig(id: id)
        let workflowDetails = try Failure.wrap("Reading workflow config at \(workflowConfig)") {
            let data = try Data(contentsOf: workflowConfig)
            let workflowDetails = try JSONDecoder().decode(WorkflowDetails.self, from: data)
            return workflowDetails
        }
        
        return Workflow(
            details: workflowDetails,
            storage: DirectoryCodableStorage(at: workflowPath(id: id))
        )
    }
    
    private func workflowPath(id: WorkflowId) -> URL {
        directory.appending(path: id.rawValue)
    }
    
    private func workflowConfig(id: WorkflowId) -> URL {
        workflowPath(id: id).appending(path: "workflow.json")
    }
    
    private func firstFreeWorkflowId(name: String, maxRetries: Int = 10) throws -> WorkflowId {
        let timestamp = formatter.string(from: Date())
        for index in 0..<maxRetries {
            let id = WorkflowId(name: name, suffix: "\(timestamp)-\(index)")
            
            if !fileManager.fileExists(atPath: workflowPath(id: id).path()) {
                return id
            }
        }
        
        throw Failure("Not found free folder for \(name) after \(maxRetries) tries, clean workflows folder or increase limit")
    }
}
