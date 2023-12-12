//
//  DynamicWorkflowLoader.swift
//
//
//  Created by Vlad Maltsev on 06.12.2023.
//

import Prelude
import LocalStorage
import os

public struct DynamicWorkflowLoader {
    private var loaders: [WorkflowType: AnyWorkflowLoader] = [:]
    private let logger = Logger(scope: .global)
    
    public init(loaders: [AnyWorkflowLoader]) {
        self.loaders = Dictionary(grouping: loaders, by: { $0.type })
            .compactMapValues { loaders in
                guard let firstLoader = loaders.first else {
                    return nil
                }
                
                if loaders.count > 1 {
                    logger.warning("There is more than 1 loader for \(firstLoader.type): \(loaders)")
                }
                
                return firstLoader
            }
    }
    
    public init(@ArrayBuilder<AnyWorkflowLoader> builder: () -> [AnyWorkflowLoader]) {
        self.init(loaders: builder())
    }
    
    public func load<Dependencies>(details: WorkflowDetails, from storage: WorkflowStorage, dependencies: Dependencies) throws -> AnyWorkflow {
        guard let loader = loaders[details.type] else {
            throw Failure("Failed to find loader for \(details.type)")
        }
        
        return try loader.load(from: storage, dependencies: dependencies)
    }
}
