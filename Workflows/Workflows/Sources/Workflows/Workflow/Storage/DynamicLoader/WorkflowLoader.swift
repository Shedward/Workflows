//
//  WorkflowLoader.swift
//
//
//  Created by Vlad Maltsev on 06.12.2023.
//

import Foundation
import Prelude
import LocalStorage

public struct WorkflowLoader<S: State>: AnyWorkflowLoader {
    public let type: WorkflowType
    
    public init(_ type: S.Type) {
        self.type = WorkflowType(type)
    }
    
    public init(id: WorkflowType, type: S.Type) {
        self.type = id
    }
    
    public func load<Dependencies>(from storage: CodableStorage, dependencies: Dependencies) throws -> AnyWorkflow {
        guard let workflowsDependencies = dependencies as? S.Dependencies else {
            throw Failure("Can't cast \(Swift.type(of: dependencies)) to \(S.Dependencies.self)")
        }
        let workflow = try Workflow<S>.load(storage: storage, dependencies: workflowsDependencies)
        return workflow.asAny()
    }
}
