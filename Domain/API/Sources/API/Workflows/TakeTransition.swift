//
//  TakeTransition.swift
//  API
//
//  Created by Vlad Maltsev on 10.01.2026.
//

import Core
import Rest

public struct TakeTransition: WorkflowApi {
    public typealias ResponseBody = WorkflowInstance

    static public let method = Method.post
    static public let path = "/workflows/:id/takeTransition"

    public let instanceId: String
    public let transitionProcessId: String

    public var request: RouteRequest {
        request(
            .init("id", to: instanceId),
            body: RequestBody(transitionProcessId: transitionProcessId)
        )
    }

    public init(instanceId: String, transitionProcessId: String) {
        self.instanceId = instanceId
        self.transitionProcessId = transitionProcessId
    }
}

extension TakeTransition {
    public struct RequestBody: JSONBody {
        public let transitionProcessId: String
    }
}
