//
//  RetryTransition.swift
//  API
//

import Rest

public struct RetryTransition: WorkflowApi {
    public typealias ResponseBody = WorkflowInstance

    public static let method = Method.post
    public static let path = "/workflowInstances/:id/retry"

    public let instanceId: String

    public var request: RouteRequest {
        request(
            .init("id", to: instanceId)
        )
    }

    public init(instanceId: String) {
        self.instanceId = instanceId
    }
}
