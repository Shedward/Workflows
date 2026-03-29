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
    private static func discoverSubflows(in workflows: [AnyWorkflow]) -> [AnyWorkflow] {
        var discovered: [WorkflowID: AnyWorkflow] = [:]
        var queue: [AnyWorkflow] = workflows

        while let workflow = queue.popLast() {
            guard discovered[workflow.id] == nil else { continue }
            discovered[workflow.id] = workflow

            for transition in workflow.anyTransitions {
                if let subflow = transition.process as? AnyWorkflow, discovered[subflow.id] == nil {
                    queue.append(subflow)
                }
            }
        }

        return Array(discovered.values)
    }

    private var workflows: [WorkflowID: AnyWorkflow] = [:]
    private var graphs: [WorkflowID: WorkflowGraph] = [:]

    public init(_ workflows: [AnyWorkflow]) throws {
        let allWorkflows = Self.discoverSubflows(in: workflows)
        self.workflows = .init(uniqueKeysWithValues: allWorkflows.map { ($0.id, $0) })

        if allWorkflows.count != self.workflows.count {
            let ids = allWorkflows.map(\.id)
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

        let orderedWorkflows = topologicalWorkflowOrder()

        for workflow in orderedWorkflows {
            let result = WorkflowValidator.validate(
                workflow: workflow,
                dependencies: dependencies,
                graphBuilder: &graphBuilder
            )

            let graph = graphBuilder.build(from: workflow)
            graphs[workflow.id] = graph

            for warning in result.warnings {
                logger?.warning("[\(workflow.id, privacy: .public)] \(warning.description, privacy: .public)")
            }

            if !result.isValid {
                for error in result.errors {
                    logger?.error("[\(workflow.id, privacy: .public)] \(error.description, privacy: .public)")
                }
                results.append(result)
            }
        }

        let circularCycles = detectCircularSubflows()
        for cycle in circularCycles {
            let description = ValidationError.circularSubflow(cycle).description
            logger?.error("\(description, privacy: .public)")
        }
        if !circularCycles.isEmpty, mode == .strict {
            throw WorkflowsError.CircularSubflows(cycles: circularCycles)
        }

        if mode == .strict, !results.isEmpty {
            throw WorkflowsError.ValidationFailed(results: results)
        }
    }

    private func topologicalWorkflowOrder() -> [AnyWorkflow] {
        var visited: Set<WorkflowID> = []
        var ordered: [AnyWorkflow] = []

        func visit(_ workflowId: WorkflowID) {
            guard !visited.contains(workflowId), let workflow = workflows[workflowId] else {
                return
            }
            visited.insert(workflowId)
            for transition in workflow.anyTransitions {
                if let subflow = transition.process as? AnyWorkflow {
                    visit(subflow.id)
                }
            }
            ordered.append(workflow)
        }

        for workflowId in workflows.keys.sorted() {
            visit(workflowId)
        }

        return ordered
    }

    private func detectCircularSubflows() -> [[WorkflowID]] {
        var visited: Set<WorkflowID> = []
        var inProgress: Set<WorkflowID> = []
        var cycles: [[WorkflowID]] = []

        func dfs(_ workflowId: WorkflowID, path: [WorkflowID]) {
            guard let workflow = workflows[workflowId] else {
                return
            }
            guard !visited.contains(workflowId) else {
                return
            }

            inProgress.insert(workflowId)

            for transition in workflow.anyTransitions {
                guard let subflow = transition.process as? AnyWorkflow else { continue }
                let subflowId = subflow.id

                if inProgress.contains(subflowId) {
                    let cycleStart = path.firstIndex(of: subflowId) ?? 0
                    cycles.append(Array(path[cycleStart...]) + [subflowId])
                } else if !visited.contains(subflowId) {
                    dfs(subflowId, path: path + [subflowId])
                }
            }

            inProgress.remove(workflowId)
            visited.insert(workflowId)
        }

        for workflowId in workflows.keys {
            dfs(workflowId, path: [workflowId])
        }

        return cycles
    }
}
