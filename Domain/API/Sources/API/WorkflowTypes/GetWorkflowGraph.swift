//
//  GetWorkflowGraph.swift
//  API
//
//  Created by Мальцев Владислав on 03.04.2026.
//

import Rest

public struct GetWorkflowGraph: WorkflowApi {
    public typealias ResponseBody = WorkflowGraph

    public static let method = Method.get
    public static let path = "/workflows/:id/graph"

    public let workflowId: String

    public var request: RouteRequest {
        request(.init("id", to: workflowId))
    }

    public init(workflowId: String) {
        self.workflowId = workflowId
    }
}
