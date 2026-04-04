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

    private func getWorkflowStarting(request: Request, body: EmptyBody, context: Context) async throws -> ListBody<API.WorkflowStartCandidate> {
        let workflowId = try context.parameters.require("id")
        let candidates = try await workflows.starting(for: workflowId)
        let apiCandidates = candidates.map { API.WorkflowStartCandidate(model: $0) }
        return ListBody(items: apiCandidates)
    }
}
