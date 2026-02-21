//
//  GetWorkflowTypes.swift
//  API
//
//  Created by Vlad Maltsev on 20.02.2026.
//

import Rest

public struct GetWorkflows: WorkflowApi {
    public typealias ResponseBody = ListBody<Workflow>

    static public let method = Method.get
    static public let path = "/workflows"
}
