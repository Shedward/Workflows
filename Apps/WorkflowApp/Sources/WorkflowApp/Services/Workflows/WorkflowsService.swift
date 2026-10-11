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
    let rest: WorkflowServerClient

    init(rest: any RestClient) {
        self.rest = WorkflowServerClient(rest)
    }

    init(endpoint: NetworkRestClient.Endpoint) {
        self.rest = WorkflowServerClient(endpoint: endpoint)
    }

    func getWorkflowInstances() async throws -> [WorkflowInstance] {
        try await rest.fetch(GetWorkflowsInstances()).items
    }

    func getStartingWorkflows() async throws -> [WorkflowStart] {
        try await rest.fetch(GetStartingWorkflows()).items
    }

    func startWorkflow(_ start: WorkflowStart) async throws -> WorkflowInstance {
        try await rest.fetch(StartWorkflow(workflowId: start.workflowId, initialData: start.data))
    }

    func getTransitions(instanceId: String) async throws -> [API.Transition] {
        try await rest.fetch(AvailableTransitions(instanceId: instanceId)).items
    }

    func takeTransition(instanceId: String, transitionProcessId: String) async throws -> WorkflowInstance {
        try await rest.fetch(TakeTransition(instanceId: instanceId, transitionProcessId: transitionProcessId))
    }

    func retryTransition(instanceId: String) async throws -> WorkflowInstance {
        try await rest.fetch(RetryTransition(instanceId: instanceId))
    }
}
