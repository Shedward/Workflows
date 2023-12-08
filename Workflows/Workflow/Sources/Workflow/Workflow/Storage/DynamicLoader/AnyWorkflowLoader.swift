//
//  AnyWorkflowLoader.swift
//
//
//  Created by Vlad Maltsev on 06.12.2023.
//

import LocalStorage

public protocol AnyWorkflowLoader {
    var type: WorkflowType { get }
    func load<Dependencies>(from storage: CodableStorage, dependencies: Dependencies) throws -> AnyWorkflow
}
