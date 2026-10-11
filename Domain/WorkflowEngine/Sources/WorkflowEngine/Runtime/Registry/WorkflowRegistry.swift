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

    /// Registers the given workflows and every subflow they reach. The same type may appear more
    /// than once; two different types with one id cannot both be registered, so that is an error.
    public init(_ workflows: [AnyWorkflow]) throws {
        var queue = workflows

        while let workflow = queue.popLast() {
            if let registered = self.workflows[workflow.id] {
                guard ObjectIdentifier(type(of: registered)) == ObjectIdentifier(type(of: workflow)) else {
                    throw WorkflowsError.DuplicateWorkflowID(
                        workflowId: workflow.id,
                        types: [String(describing: type(of: registered)), String(describing: type(of: workflow))]
                    )
                }
                continue
            }
            self.workflows[workflow.id] = workflow
            queue.append(contentsOf: workflow.subflows)
        }
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
        let (subflowsFirst, subflowCycles) = subflowNesting()
        var graphBuilder = WorkflowGraphBuilder()
        var invalidResults: [WorkflowValidationResult] = []

        for workflow in subflowsFirst {
            let result = WorkflowValidator.validate(
                workflow: workflow,
                dependencies: dependencies,
                graphBuilder: &graphBuilder
            )
            graphs[workflow.id] = graphBuilder.build(from: workflow)

            for warning in result.warnings {
                logger?.warning("[\(workflow.id, privacy: .public)] \(warning.description, privacy: .public)")
            }
            for error in result.errors {
                logger?.error("[\(workflow.id, privacy: .public)] \(error.description, privacy: .public)")
            }
            if !result.isValid {
                invalidResults.append(result)
            }
        }

        for cycle in subflowCycles {
            let description = ValidationError.circularSubflow(cycle).description
            logger?.error("\(description, privacy: .public)")
        }

        guard mode == .strict else {
            return
        }
        if !subflowCycles.isEmpty {
            throw WorkflowsError.CircularSubflows(cycles: subflowCycles)
        }
        if !invalidResults.isEmpty {
            throw WorkflowsError.ValidationFailed(results: invalidResults)
        }
    }

    private func subflowNesting() -> (subflowsFirst: [AnyWorkflow], cycles: [[WorkflowID]]) {
        var visited: Set<WorkflowID> = []
        var subflowsFirst: [AnyWorkflow] = []
        var cycles: [[WorkflowID]] = []

        func visit(_ workflowId: WorkflowID, parents: [WorkflowID]) {
            guard let workflow = workflows[workflowId] else {
                return
            }
            visited.insert(workflowId)
            let pathFromRoot = parents + [workflowId]

            for subflowId in workflow.subflows.map(\.id) {
                if let cycleStart = pathFromRoot.firstIndex(of: subflowId) {
                    cycles.append(Array(pathFromRoot[cycleStart...]) + [subflowId])
                } else if !visited.contains(subflowId) {
                    visit(subflowId, parents: pathFromRoot)
                }
            }

            subflowsFirst.append(workflow)
        }

        for workflowId in workflows.keys.sorted() where !visited.contains(workflowId) {
            visit(workflowId, parents: [])
        }

        return (subflowsFirst, cycles)
    }
}

private extension AnyWorkflow {
    var subflows: [AnyWorkflow] {
        anyTransitions.compactMap { $0.process as? AnyWorkflow }
    }
}
