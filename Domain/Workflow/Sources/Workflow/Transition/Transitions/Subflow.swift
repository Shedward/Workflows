//
//  Workflow+TransitionProcess.swift
//  Workflow
//
//  Created by Vlad Maltsev on 29.12.2025.
//

public extension Workflow where Self: TransitionProcess {
    func start(context: inout WorkflowContext) async throws -> TransitionResult {
        let subflowInstance = try await context.start(self, context.data)
        return .waiting(.workflowFinished(.init(id: subflowInstance.id)))
    }
}
