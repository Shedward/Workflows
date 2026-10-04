//
//  WorkflowStart.swift
//  API
//

import Foundation
import Rest

public struct WorkflowStart: JSONBody, Hashable, Identifiable {
    public let id: String
    public let workflowId: String
    public let title: String?
    public let data: WorkflowData

    public init(id: String = UUID().uuidString, workflowId: String, title: String?, data: WorkflowData) {
        self.id = id
        self.workflowId = workflowId
        self.title = title
        self.data = data
    }
}
