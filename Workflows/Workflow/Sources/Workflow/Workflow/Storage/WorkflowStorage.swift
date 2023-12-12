//
//  WorkflowStorage.swift
//
//
//  Created by Vlad Maltsev on 12.12.2023.
//

import LocalStorage

public struct WorkflowStorage {
    public let data: CodableStorage
    internal let deleteAllWorkflowData: () async throws -> Void
    
    init(data: CodableStorage, deleteAllWorkflowData: @escaping () async throws -> Void) {
        self.data = data
        self.deleteAllWorkflowData = deleteAllWorkflowData
    }
    
    public static var mock: WorkflowStorage {
        .init(data: InMemoryCodableStorage(), deleteAllWorkflowData: { })
    }
}
