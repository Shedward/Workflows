//
//  Workflow+TransitionProcess.swift
//  Workflow
//
//  Created by Vlad Maltsev on 29.12.2025.
//

import Core
import os

public extension Workflow where Self: TransitionProcess {
    func start(context: inout WorkflowContext) async throws -> TransitionResult {
        if context.resume == .workflowFinished {
            return .completed
        }

        let subflowInstance = try await context.start(self, filteredData(from: context.instance.data))

        // If child already finished (all automatic transitions completed inline),
        // skip waiting and complete immediately
        if subflowInstance.state == self.finishId {
            return .completed
        }

        return .waiting(.workflowFinished(.init(id: subflowInstance.id)))
    }

    private func filteredData(from parentData: WorkflowData) -> WorkflowData {
        let declaredInputKeys = self.collectMetadata().inputKeys
        guard !declaredInputKeys.isEmpty else {
            return parentData
        }

        let undeclaredKeys = Set(parentData.data.keys).subtracting(declaredInputKeys)
        if !undeclaredKeys.isEmpty {
            let logger = Logger(scope: .workflow)
            let keyList = undeclaredKeys.sorted().joined(separator: ", ")
            // swiftlint:disable:next line_length
            logger?.warning("Subflow '\(self.id, privacy: .public)' filtered \(undeclaredKeys.count) undeclared key(s) from parent data: \(keyList, privacy: .public). Declare @Input properties on the subflow to use this data.")
        }

        return WorkflowData(data: parentData.data.filter { declaredInputKeys.contains($0.key) })
    }
}
