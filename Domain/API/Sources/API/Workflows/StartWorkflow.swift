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
    static public let path = "/workflows"

    let workflowId: String
    let initialData: String

    public var request: RouteRequest {
        request(body: RequestBody(workflowID: workflowId, initialData: initialData))
    }
}

extension StartWorkflow {
    public struct RequestBody: JSONBody {
        public let workflowID: String
        public let initialData: String

        init(workflowID: String, initialData: String) {
            self.workflowID = workflowID
            self.initialData = initialData
        }
    }
}
