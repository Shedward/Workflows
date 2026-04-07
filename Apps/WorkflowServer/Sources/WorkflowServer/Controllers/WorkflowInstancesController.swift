//
//  WorkflowsController.swift
//  WorkflowServer
//
//  Created by Vlad Maltsev on 08.01.2026.
//

import API
import Core
import Hummingbird
import Rest
import WorkflowEngine

struct WorkflowInstancesController: Controller {
    static let defaultTimeout: Double = 5.0

    let workflows: Workflows

    var endpoints: RouteCollection<AppRequestContext> {
        RouteCollection()
            .on(GetWorkflowsInstances.self, use: getWorkflows)
            .on(StartWorkflow.self, use: startWorkflow)
            .on(GetWorkflowInstance.self, use: getWorkflow)
            .on(TakeTransition.self, use: takeTransition)
            .on(AvailableTransitions.self, use: availableTransitions)
            .on(AnswerAsk.self, use: answerAsk)
    }

    private func getWorkflows(request: Request, body: GetWorkflows.RequestBody, context: Context) async throws -> ListBody<API.WorkflowInstance> {
        let allWorkflows = try await workflows.instances()
        let instances = allWorkflows.map { API.WorkflowInstance(model: $0) }
        return ListBody(items: instances)
    }

    private func getWorkflow(request: Request, body: EmptyBody, context: Context) async throws -> API.WorkflowInstance {
        let workflowId = try context.parameters.require("id")
        let workflow = try await workflows.instance(id: workflowId)
        if workflow.finishedAt != nil {
            throw WorkflowsError.WorkflowInstanceFinished(instance: workflow)
        }
        return API.WorkflowInstance(model: workflow)
    }

    private func startWorkflow(request: Request, body: StartWorkflow.RequestBody, context: Context) async throws -> API.WorkflowInstance {
        let timeout = self.timeout(from: request)
        let initialData = body.initialData.map { WorkflowData(api: $0) } ?? WorkflowData()

        let created = try await workflows.create(body.workflowId, initialData: initialData)

        let result = await withTimeout(seconds: timeout) { [workflows] in
            try await workflows.runAutomaticTransitions(on: created.id)
        }

        switch result {
        case .completed(.success(let instance)):
            return API.WorkflowInstance(model: instance)
        case .completed(.failure(let error)):
            throw error
        case .timedOut:
            let current = try await workflows.instance(id: created.id)
            return API.WorkflowInstance(model: current)
        }
    }

    private func takeTransition(request: Request, body: TakeTransition.RequestBody, context: Context) async throws -> API.WorkflowInstance {
        let instanceId = try context.parameters.require("id")
        let timeout = self.timeout(from: request)
        let transitionProcessId = body.transitionProcessId

        let result = await withTimeout(seconds: timeout) { [workflows] in
            try await workflows.takeTransition(processId: transitionProcessId, on: instanceId)
        }

        switch result {
        case .completed(.success(let instance)):
            return API.WorkflowInstance(model: instance)
        case .completed(.failure(let error)):
            throw error
        case .timedOut:
            let current = try await workflows.instance(id: instanceId)
            return API.WorkflowInstance(model: current)
        }
    }

    private func answerAsk(request: Request, body: AnswerAsk.RequestBody, context: Context) async throws -> API.WorkflowInstance {
        let instanceId = try context.parameters.require("id")
        let timeout = self.timeout(from: request)
        let data = WorkflowData(api: body.data)

        let result = await withTimeout(seconds: timeout) { [workflows] in
            try await workflows.answer(to: instanceId, data: data)
        }

        switch result {
        case .completed(.success(let instance)):
            return API.WorkflowInstance(model: instance)
        case .completed(.failure(let error)):
            throw error
        case .timedOut:
            let current = try await workflows.instance(id: instanceId)
            return API.WorkflowInstance(model: current)
        }
    }

    private func availableTransitions(
        request: Request,
        body: AvailableTransitions.RequestBody,
        context: Context
    ) async throws -> ListBody<API.Transition> {
        let workflowId = try context.parameters.require("id")
        let transitions = try await workflows.transitions(for: workflowId)
        let apiTransitions = transitions.map { transition in
            API.Transition(model: transition)
        }
        return ListBody(items: apiTransitions)
    }

    private func timeout(from request: Request) -> Double {
        request.uri.queryParameters["timeout"]
            .flatMap { Double($0) }
            ?? Self.defaultTimeout
    }
}
