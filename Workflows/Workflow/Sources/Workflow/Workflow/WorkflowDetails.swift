//
//  WorkflowDetails.swift
//
//
//  Created by Vlad Maltsev on 07.10.2023.
//

public struct WorkflowDetails: Codable, Hashable {
    public let id: WorkflowId
    public let type: WorkflowType
    public let name: String
}
