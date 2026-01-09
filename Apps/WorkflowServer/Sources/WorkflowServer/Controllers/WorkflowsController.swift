//
//  WorkflowsController.swift
//  WorkflowServer
//
//  Created by Vlad Maltsev on 08.01.2026.
//

import API
import Rest
import Hummingbird
import WorkflowEngine

struct WorkflowsController: Sendable {
    typealias Context = AppRequestContext

    let workflows: Workflows

    var endpoints: RouteCollection<AppRequestContext> {
        RouteCollection()
            .on(GetWorkflows.self, use: getWorkflows)
            .on(StartWorkflow.self, use: startWorkflow)
    }

    private func getWorkflows(request: Request, body: EmptyBody, context: AppRequestContext) async throws -> ListBody<API.WorkflowInstance> {
        let allWorkflows = try await workflows.instances()
        let instances = try allWorkflows.map { try API.WorkflowInstance(model: $0) }
        return ListBody(items: instances)
    }

    private func startWorkflow(request: Request, body: StartWorkflow.RequestBody, context: AppRequestContext) async throws -> API.WorkflowInstance {
        let workflowInstance = try await workflows.start(body.workflowID)
        let instance = try API.WorkflowInstance(model: workflowInstance)
        return instance
    }
}
