//
//  WorkflowsController.swift
//  WorkflowServer
//
//  Created by Vlad Maltsev on 08.01.2026.
//

import API
import RestClient
import Hummingbird
import Workflow

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
        // TODO: Simplify mapping
        let instances = allWorkflows.map { instance in
            API.WorkflowInstance(id: instance.id, workflowId: instance.workflowId, state: instance.state, data: [:]) // TODO: Fix data
        }
        return ListBody(items: instances)
    }

    private func startWorkflow(request: Request, body: StartWorkflow.RequestBody, context: AppRequestContext) async throws -> API.WorkflowInstance {
        let workflowInstance = try await workflows.start(body.workflowID)
        let instance = API.WorkflowInstance(id: workflowInstance.id, workflowId: workflowInstance.workflowId, state: workflowInstance.state, data: [:]) // TODO: Fix data
        return instance
    }
}
