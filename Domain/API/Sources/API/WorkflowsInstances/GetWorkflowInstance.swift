//
//  GetWorkflowInstance.swift
//  API
//
//  Created by Vlad Maltsev on 21.02.2026.
//

import Rest

public struct GetWorkflowInstance: WorkflowApi {
    public typealias ResponseBody = WorkflowInstance

    static public let method = Method.get
    static public let path = "/workflowInstances/:id"

    public let instanceId: String
    public let transitionProcessId: String

    public var request: RouteRequest {
        request(
            .init("id", to: instanceId)
        )
    }
}
