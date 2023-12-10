//
//  WorkflowDetails.swift
//
//
//  Created by Vlad Maltsev on 07.10.2023.
//

public struct WorkflowDetails: Codable, Hashable {
    public let id: WorkflowId
    public let type: WorkflowType
    public let key: String?
    public let name: String?
    
    public init(id: WorkflowId, type: WorkflowType, key: String?, name: String?) {
        self.id = id
        self.type = type
        self.key = key
        self.name = name
    }
}
