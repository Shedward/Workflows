//
//  GetWorkflowTypes.swift
//  API
//
//  Created by Vlad Maltsev on 20.02.2026.
//

import Rest

public struct GetWorkflows: WorkflowApi {
    public typealias ResponseBody = ListBody<Workflow>

    public static let method = Method.get
    public static let path = "/workflows"

    public init() {
    }
}
