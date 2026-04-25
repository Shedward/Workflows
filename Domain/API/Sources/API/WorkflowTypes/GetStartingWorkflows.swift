//
//  GetStartingWorkflows.swift
//  API
//

import Rest

public struct GetStartingWorkflows: WorkflowApi {
    public typealias ResponseBody = ListBody<WorkflowStart>

    public static let method = Method.get
    public static let path = "/startingWorkflows"

    public init() {}
}
