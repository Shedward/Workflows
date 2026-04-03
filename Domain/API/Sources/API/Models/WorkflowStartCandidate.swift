//
//  WorkflowStartCandidate.swift
//  API
//
//  Created by Claude on 03.04.2026.
//

import Rest

public struct WorkflowStartCandidate: JSONBody {
    public let id: String
    public let title: String?
    public let workflowId: String
    public let data: WorkflowData
    public let inputs: [DataField]

    public init(id: String, title: String?, workflowId: String, data: WorkflowData, inputs: [DataField]) {
        self.id = id
        self.title = title
        self.workflowId = workflowId
        self.data = data
        self.inputs = inputs
    }
}
