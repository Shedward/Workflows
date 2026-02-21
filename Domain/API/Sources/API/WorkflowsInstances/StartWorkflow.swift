//
//  StartWorkflow.swift
//  API
//
//  Created by Vlad Maltsev on 09.01.2026.
//

import Rest

public struct StartWorkflow: WorkflowApi {
    public typealias ResponseBody = WorkflowInstance

    static public let method = Method.post
    static public let path = "/workflowInstances"

    let workflowId: String
    let initialData: String

    public var request: RouteRequest {
        request(body: RequestBody(workflowId: workflowId, initialData: initialData))
    }
}

extension StartWorkflow {
    public struct RequestBody: JSONBody {
        public let workflowId: String
        public let initialData: String?

        init(workflowId: String, initialData: String?) {
            self.workflowId = workflowId
            self.initialData = initialData
        }
    }
}
