//
//  WorkflowsService.swift
//  WorkflowApp
//
//  Created by Мальцев Владислав on 02.04.2026.
//

import API
import Rest
import SwiftUI

struct WorkflowsService: Sendable {
    let rest: any RestClient

    init(endpoint: NetworkRestClient.Endpoint) {
        self.rest = NetworkRestClient(endpoint: endpoint)
    }

    func getWorkflowInstances() async throws -> [WorkflowInstance] {
        let request = GetWorkflowsInstances()
        return try await rest.fetch(request).items
    }

    func getStartingWorkflows() async throws -> [WorkflowStart] {
        let request = GetStartingWorkflows()
        return try await rest.fetch(request).items
    }

    func startWorkflow(_ start: WorkflowStart) async throws -> WorkflowInstance {
        let request = StartWorkflow(workflowId: start.workflowId, initialData: start.data)
        return try await rest.fetch(request)
    }
}
