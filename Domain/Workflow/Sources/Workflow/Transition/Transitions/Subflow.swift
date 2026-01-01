//
//  Workflow+TransitionProcess.swift
//  Workflow
//
//  Created by Vlad Maltsev on 29.12.2025.
//

extension Workflow where Self: TransitionProcess {
    public func start(context: WorkflowContext) async throws -> TransitionResult {
        let subflowInstance = try await context.start(self)
        return .waiting(.workflowFinished(.init(id: subflowInstance.id)))
    }
}
