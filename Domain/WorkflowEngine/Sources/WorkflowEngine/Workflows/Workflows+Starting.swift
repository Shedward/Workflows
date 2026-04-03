//
//  Workflows+Starting.swift
//  WorkflowEngine
//
//  Created by Claude on 03.04.2026.
//

import Core

public extension Workflows {
    func starting(for workflowId: WorkflowID) async throws -> [WorkflowStartCandidate] {
        let workflow = try await workflow(id: workflowId)
        let graph = await registry.graph(for: workflowId)
        let requiredInputs = graph?.requiredInputs ?? []

        var candidates: [WorkflowStartCandidate] = []

        for provider in workflow.providers {
            let resolved = try resolveProvider(provider)
            let starts = try await resolved.starting()
            for start in starts {
                candidates.append(WorkflowStartCandidate(
                    title: start.title,
                    workflowId: workflowId,
                    data: start.data,
                    inputs: requiredInputs
                ))
            }
        }

        return candidates
    }

    private func resolveProvider(_ provider: any WorkflowStartProvider) throws -> any WorkflowStartProvider {
        var provider = provider
        try provider.bind(SetDependencies(container: dependencies))
        return provider
    }
}
