//
//  AnswerAsk.swift
//  API
//
//  Created by Vlad Maltsev on 04.04.2026.
//

import Rest

public struct AnswerAsk: WorkflowApi {
    public typealias ResponseBody = WorkflowInstance

    public static let method = Method.post
    public static let path = "/workflowInstances/:id/answer"

    public let instanceId: String
    public let data: WorkflowData

    public var request: RouteRequest {
        request(
            .init("id", to: instanceId),
            body: RequestBody(data: data)
        )
    }

    public init(instanceId: String, data: WorkflowData) {
        self.instanceId = instanceId
        self.data = data
    }
}

extension AnswerAsk {
    public struct RequestBody: JSONBody {
        public let data: WorkflowData
    }
}
