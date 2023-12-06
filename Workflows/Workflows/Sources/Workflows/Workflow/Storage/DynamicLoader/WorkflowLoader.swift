//
//  WorkflowLoader.swift
//
//
//  Created by Vlad Maltsev on 06.12.2023.
//

import Foundation
import LocalStorage

public struct WorkflowLoader<S: State>: AnyWorkflowLoader {
    public let type: WorkflowType
    
    public init(_ type: S.Type) {
        self.type = WorkflowType(type)
    }
    
    public init(id: WorkflowType, type: S.Type) {
        self.type = id
    }
    
    public func load(from storage: CodableStorage) throws -> AnyWorkflow {
        let workflow = try Workflow<S>.load(storage: storage)
        return workflow.asAny()
    }
}
