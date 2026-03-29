//
//  WorkflowRegistry.swift
//  Workflow
//
//  Created by Vlad Maltsev on 26.12.2025.
//

import Core
import Foundation
import os

public actor WorkflowRegistry {
    private var workflows: [WorkflowID: AnyWorkflow] = [:]
    private var graphs: [WorkflowID: WorkflowGraph] = [:]

    public init(_ workflows: [AnyWorkflow]) throws {
        self.workflows = .init(uniqueKeysWithValues: workflows.map { ($0.id, $0) })

        if workflows.count != self.workflows.count {
            let ids = workflows.map(\.id)
            let registeredIds = self.workflows.keys
            throw Failure("Failed to register workflows. Expected \(ids), registered: \(registeredIds)")
        }
    }

    public func register(_ workflow: AnyWorkflow) {
        self.workflows[workflow.id] = workflow
    }

    public func workflow(instance: WorkflowInstance) -> AnyWorkflow? {
        workflow(id: instance.workflowId)
    }

    public func workflow(id: WorkflowID) -> AnyWorkflow? {
        workflows[id]
    }

    public func allWorkflows() -> [AnyWorkflow] {
        Array(workflows.values.sorted(using: SortDescriptor(\.id, comparator: .lexical)))
    }

    public func graph(for workflowId: WorkflowID) -> WorkflowGraph? {
        graphs[workflowId]
    }

    public func validateAll(dependencies: DependenciesContainer, mode: ValidationMode) throws {
        let logger = Logger(scope: .workflow)
        var graphBuilder = WorkflowGraphBuilder()
        var results: [WorkflowValidationResult] = []

        for workflow in workflows.values {
            let result = WorkflowValidator.validate(
                workflow: workflow,
                dependencies: dependencies,
                graphBuilder: &graphBuilder
            )

            let graph = graphBuilder.build(from: workflow)
            graphs[workflow.id] = graph

            for warning in result.warnings {
                logger?.warning("[\(workflow.id)] \(warning.description)")
            }

            if !result.isValid {
                for error in result.errors {
                    logger?.error("[\(workflow.id)] \(error.description)")
                }
                results.append(result)
            }
        }

        if mode == .strict, !results.isEmpty {
            throw WorkflowsError.ValidationFailed(results: results)
        }
    }
}
