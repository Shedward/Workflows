//
//  StartWorkflow.swift
//  API
//
//  Created by Vlad Maltsev on 09.01.2026.
//

import Rest

public struct StartWorkflow: WorkflowApi {
    public typealias ResponseBody = WorkflowInstance

    public static let method = Method.post
    public static let path = "/workflowInstances"

    public let workflowId: String
    public let initialData: WorkflowData?

    public init(workflowId: String, initialData: WorkflowData? = nil) {
        self.workflowId = workflowId
        self.initialData = initialData
    }

    public var request: RouteRequest {
        request(body: RequestBody(workflowId: workflowId, initialData: initialData))
    }
}

extension StartWorkflow {
    public struct RequestBody: JSONBody {
        public let workflowId: String
        public let initialData: WorkflowData?
    }
}
