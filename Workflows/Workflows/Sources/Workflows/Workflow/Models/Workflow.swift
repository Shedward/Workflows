//
//  Workflow.swift
//
//
//  Created by Vlad Maltsev on 22.10.2023.
//

import LocalStorage

public struct Workflow {
    public let id: WorkflowId
    public let name: String
    public let storage: CodableStorage
    
    init(details: WorkflowDetails, storage: CodableStorage) {
        self.id = details.id
        self.name = details.name
        self.storage = storage
    }
}
