//
//  Workflows+Starting.swift
//  WorkflowEngine
//

import Core

public extension Workflows {
    func starting(for workflowId: WorkflowID) async throws -> [WorkflowStart] {
        let workflow = try await workflow(id: workflowId)
        var result: [WorkflowStart] = []
        for provider in workflow.providers {
            let resolved = try resolveProvider(provider)
            let starts = try await Failure.wrap("Getting startings") {
                try await resolved.starting()
            }
            result.append(contentsOf: starts)
        }
        return result
    }

    func allStarting() async throws -> [(workflowId: WorkflowID, start: WorkflowStart)] {
        var all: [(WorkflowID, WorkflowStart)] = []
        for workflow in await workflows() {
            let starts = try await starting(for: workflow.id)
            all.append(contentsOf: starts.map { (workflow.id, $0) })
        }
        return all
    }

    private func resolveProvider(_ provider: any WorkflowStartProvider) throws -> any WorkflowStartProvider {
        var provider = provider
        try provider.bind(SetDependencies(container: dependencies))
        return provider
    }
}
