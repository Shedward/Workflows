//
//  GetWorkflowStarting.swift
//  API
//
//  Created by Claude on 03.04.2026.
//

import Rest

public struct GetWorkflowStarting: WorkflowApi {
    public typealias ResponseBody = ListBody<WorkflowStartCandidate>

    public static let method = Method.get
    public static let path = "/workflows/:id/starting"

    public let workflowId: String

    public var request: RouteRequest {
        request(.init("id", to: workflowId))
    }

    public init(workflowId: String) {
        self.workflowId = workflowId
    }
}
