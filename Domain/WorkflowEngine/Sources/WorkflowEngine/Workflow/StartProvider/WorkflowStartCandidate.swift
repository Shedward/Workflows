//
//  WorkflowStartCandidate.swift
//  WorkflowEngine
//
//  Created by Claude on 03.04.2026.
//

import Foundation

public struct WorkflowStartCandidate: Sendable {
    public let id: UUID
    public let title: String?
    public let workflowId: WorkflowID
    public let data: WorkflowData
    public let inputs: Set<DataField>

    public init(id: UUID = UUID(), title: String?, workflowId: WorkflowID, data: WorkflowData, inputs: Set<DataField>) {
        self.id = id
        self.title = title
        self.workflowId = workflowId
        self.data = data
        self.inputs = inputs
    }
}
