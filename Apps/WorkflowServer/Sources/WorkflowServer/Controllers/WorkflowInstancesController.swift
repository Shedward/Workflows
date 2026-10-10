//
//  WorkflowInstancesController.swift
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
    static let maxTimeout: Double = 600.0

    let workflows: Workflows

    var endpoints: RouteCollection<AppRequestContext> {
        RouteCollection()
            .on(GetWorkflowsInstances.self, use: getInstances)
            .on(StartWorkflow.self, use: startWorkflow)
            .on(GetWorkflowInstance.self, use: getInstance)
            .on(TakeTransition.self, use: takeTransition)
            .on(AvailableTransitions.self, use: availableTransitions)
            .on(AnswerAsk.self, use: answerAsk)
    }

    private func getInstances(request: Request, body: EmptyBody, context: Context) async throws -> ListBody<API.WorkflowInstance> {
        let instances = try await workflows.instances()
        return ListBody(items: instances.map { API.WorkflowInstance(model: $0) })
    }

    private func getInstance(request: Request, body: EmptyBody, context: Context) async throws -> Response {
        let instanceId = try context.parameters.requireDecoded("id")
        let instance = try await workflows.instance(id: instanceId)
        var response = try context.responseEncoder.encode(API.WorkflowInstance(model: instance), from: request, context: context)
        if instance.finishedAt != nil {
            response.status = .gone
        }
        return response
    }

    private func startWorkflow(request: Request, body: StartWorkflow.RequestBody, context: Context) async throws -> API.WorkflowInstance {
        let initialData = body.initialData.map { WorkflowEngine.WorkflowData(api: $0) } ?? WorkflowEngine.WorkflowData()
        let created = try await workflows.create(body.workflowId, initialData: initialData)

        return try await instanceResponse(for: created.id, request: request) { [workflows] in
            try await workflows.runAutomaticTransitions(on: created.id)
        }
    }

    private func takeTransition(request: Request, body: TakeTransition.RequestBody, context: Context) async throws -> API.WorkflowInstance {
        let instanceId = try context.parameters.requireDecoded("id")
        let transitionProcessId = body.transitionProcessId

        return try await instanceResponse(for: instanceId, request: request) { [workflows] in
            try await workflows.takeTransition(processId: transitionProcessId, on: instanceId)
        }
    }

    private func answerAsk(request: Request, body: AnswerAsk.RequestBody, context: Context) async throws -> API.WorkflowInstance {
        let instanceId = try context.parameters.requireDecoded("id")
        let data = WorkflowEngine.WorkflowData(api: body.data)

        return try await instanceResponse(for: instanceId, request: request) { [workflows] in
            try await workflows.answer(to: instanceId, data: data)
        }
    }

    private func availableTransitions(
        request: Request,
        body: EmptyBody,
        context: Context
    ) async throws -> ListBody<API.Transition> {
        let instanceId = try context.parameters.requireDecoded("id")
        let transitions = try await workflows.transitions(for: instanceId)
        return ListBody(items: transitions.map { API.Transition(model: $0) })
    }

    /// Waits for `operation` up to the request's timeout and answers with the instance it returns.
    /// When the timeout comes first, the operation keeps running and the answer is the instance
    /// as it is at that moment.
    private func instanceResponse(
        for instanceId: WorkflowInstanceID,
        request: Request,
        operation: @Sendable @escaping () async throws -> WorkflowEngine.WorkflowInstance
    ) async throws -> API.WorkflowInstance {
        let instance: WorkflowEngine.WorkflowInstance
        switch await withTimeout(seconds: timeout(from: request), operation: operation) {
            case .completed(let result):
                instance = try result.get()
            case .timedOut:
                instance = try await workflows.instance(id: instanceId)
        }
        return API.WorkflowInstance(model: instance)
    }

    /// Seconds from `?timeout=`. Anything that is not a finite number means the default, and the
    /// value is kept within `0...maxTimeout`: `Task.sleep` traps on a duration it cannot represent,
    /// so `nan`, `inf` or `1e30` from a client would otherwise take the whole server down.
    private func timeout(from request: Request) -> Double {
        guard
            let raw = request.uri.queryParameters["timeout"],
            let seconds = Double(raw),
            seconds.isFinite
        else {
            return Self.defaultTimeout
        }
        return min(max(seconds, 0), Self.maxTimeout)
    }
}
