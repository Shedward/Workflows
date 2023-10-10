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
    
    public var configs: ConfigStorage {
        FileConfigStorage(at: directory.appending(component: ".configs"))
    }
    
    public var sharedCache: WorkflowsCache {
        WorkflowsCache()
    }
    
    public init(directory: URL, fileManager: FileManager = .default) {
        self.directory = directory
        self.fileManager = fileManager
    }
    
    public func workflows() -> [Workflow] {
        notImplemented()
    }
    
    public func startWorkflow(id: String) -> Workflow {
        notImplemented()
    }
}
