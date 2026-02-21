//
//  GetWorkflows.swift
//  API
//
//  Created by Vlad Maltsev on 08.01.2026.
//

import Rest

public struct GetWorkflowsInstances: WorkflowApi {
    public typealias ResponseBody = ListBody<WorkflowInstance>

    static public let method = Method.get
    static public let path = "/workflowInstances"
}
