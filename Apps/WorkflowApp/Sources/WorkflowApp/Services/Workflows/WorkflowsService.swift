//
//  WorkflowsService.swift
//  WorkflowApp
//
//  Created by Мальцев Владислав on 02.04.2026.
//

import API
import Foundation
import Rest
import SwiftUI

struct WorkflowsService: Sendable {
    let rest: any RestClient

    init(rest: any RestClient) {
        self.rest = rest
    }

    init(endpoint: NetworkRestClient.Endpoint) {
        self.init(rest: NetworkRestClient(endpoint: endpoint))
    }

    func getWorkflowInstances() async throws -> [WorkflowInstance] {
        try await fetch(GetWorkflowsInstances()).items
    }

    func getStartingWorkflows() async throws -> [WorkflowStart] {
        try await fetch(GetStartingWorkflows()).items
    }

    func startWorkflow(_ start: WorkflowStart) async throws -> WorkflowInstance {
        try await fetch(StartWorkflow(workflowId: start.workflowId, initialData: start.data))
    }

    func getTransitions(instanceId: String) async throws -> [API.Transition] {
        try await fetch(AvailableTransitions(instanceId: instanceId)).items
    }

    func takeTransition(instanceId: String, transitionProcessId: String) async throws -> WorkflowInstance {
        try await fetch(TakeTransition(instanceId: instanceId, transitionProcessId: transitionProcessId))
    }

    /// A refused response whose body is the server's `ErrorResponse` becomes a `ServerError`, so the
    /// user sees the server's explanation instead of the status code.
    private func fetch<A: Api>(_ api: A) async throws -> A.ResponseBody {
        do {
            return try await rest.fetch(api)
        } catch let rejected as ResponseRejected {
            guard let description = try? JSONDecoder().decode(ErrorDescription.self, from: rejected.body) else {
                throw rejected
            }
            throw ServerError(status: rejected.statusCode, description: description)
        }
    }
}
