//
//  WorkflowTypesController.swift
//  WorkflowServer
//
//  Created by Vlad Maltsev on 20.02.2026.
//

import API
import Hummingbird
import Rest
import WorkflowEngine

struct WorkflowsController: Controller {
    let workflows: Workflows

    var endpoints: RouteCollection<AppRequestContext> {
        RouteCollection()
            .on(GetWorkflows.self, use: getWorkflowTypes)
            .on(GetStartingWorkflows.self, use: getStartingWorkflows)
            .on(GetWorkflowGraph.self, use: getWorkflowGraph)
            .on(GetWorkflowStarting.self, use: getWorkflowStarting)
    }

    private func getWorkflowTypes(request: Request, body: EmptyBody, context: Context) async -> ListBody<API.Workflow> {
        let allWorkflows = await workflows.workflows()
        let instances = allWorkflows.map { workflow in
            API.Workflow(model: workflow)
        }
        return ListBody(items: instances)
    }

    private func getWorkflowGraph(request: Request, body: EmptyBody, context: Context) async throws -> API.WorkflowGraph {
        let workflowId = try context.parameters.require("id")
        guard let graph = await workflows.graph(for: workflowId) else {
            throw HTTPError(.notFound, message: "Workflow not found: \(workflowId)")
        }
        return API.WorkflowGraph(model: graph)
    }

    private func getStartingWorkflows(request: Request, body: EmptyBody, context: Context) async throws -> ListBody<API.WorkflowStart> {
        let pairs = try await workflows.allStarting()
        return ListBody(items: pairs.map { API.WorkflowStart(model: $0.start, workflowId: $0.workflowId) })
    }

    private func getWorkflowStarting(request: Request, body: EmptyBody, context: Context) async throws -> ListBody<API.WorkflowStart> {
        let workflowId = try context.parameters.require("id")
        let starts = try await workflows.starting(for: workflowId)
        return ListBody(items: starts.map { API.WorkflowStart(model: $0, workflowId: workflowId) })
    }
}
