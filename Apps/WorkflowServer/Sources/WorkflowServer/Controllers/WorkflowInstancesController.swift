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

struct WorkflowInstancesController: Controller {
    let workflows: Workflows

    var endpoints: RouteCollection<AppRequestContext> {
        RouteCollection()
            .on(GetWorkflowsInstances.self, use: getWorkflows)
            .on(StartWorkflow.self, use: startWorkflow)
            .on(GetWorkflowInstance.self, use: getWorkflow)
            .on(TakeTransition.self, use: startWorkflow)
            .on(AvailableTransitions.self, use: availableTransitions)
    }

    private func getWorkflows(request: Request, body: GetWorkflows.RequestBody, context: Context) async throws -> ListBody<API.WorkflowInstance> {
        let allWorkflows = try await workflows.instances()
        let instances = allWorkflows.map { API.WorkflowInstance(model: $0) }
        return ListBody(items: instances)
    }

    private func getWorkflow(request: Request, body: EmptyBody, context: Context) async throws -> API.WorkflowInstance {
        let workflowId = try context.parameters.require("id")
        let workflow = try await workflows.instance(id: workflowId)
        let instance = API.WorkflowInstance(model: workflow)
        return instance
    }

    private func startWorkflow(request: Request, body: StartWorkflow.RequestBody, context: Context) async throws -> API.WorkflowInstance {
        let workflowInstance = try await workflows.start(body.workflowId)
        let instance = API.WorkflowInstance(model: workflowInstance)
        return instance
    }

    private func startWorkflow(request: Request, body: TakeTransition.RequestBody, context: Context) async throws -> API.WorkflowInstance {
        let workflowId = try context.parameters.require("id")
        let transitionProcessId = body.transitionProcessId

        let nextInstance = try await workflows.takeTransition(processId: transitionProcessId, on: workflowId)

        return API.WorkflowInstance(model: nextInstance)
    }

    private func availableTransitions(request: Request, body: AvailableTransitions.RequestBody, context: Context) async throws -> ListBody<API.Transition> {
        let workflowId = try context.parameters.require("id")
        let transitions = try await workflows.transitions(for: workflowId)
        let apiTransitions = transitions.map { transition in
            API.Transition(
                processId: transition.process.id,
                fromState: transition.id.from,
                toState: transition.id.to
            )
        }
        return ListBody(items: apiTransitions)
    }
}
