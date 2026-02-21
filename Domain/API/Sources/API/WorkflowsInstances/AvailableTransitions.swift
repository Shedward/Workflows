//
//  AvailableTransitions.swift
//  API
//
//  Created by Vlad Maltsev on 21.02.2026.
//

import Core
import Rest

public struct AvailableTransitions: WorkflowApi {
    public typealias ResponseBody = ListBody<Transition>

    static public let method = Method.get
    static public let path = "/workflowInstances/:id/transitions"

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
