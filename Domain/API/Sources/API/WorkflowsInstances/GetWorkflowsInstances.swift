//
//  GetWorkflows.swift
//  API
//
//  Created by Vlad Maltsev on 08.01.2026.
//

import Rest

public struct GetWorkflowsInstances: WorkflowApi {
    public typealias ResponseBody = ListBody<WorkflowInstance>

    public static let method = Method.get
    public static let path = "/workflowInstances"
}
