//
//  Workflow+TransitionProcess.swift
//  Workflow
//
//  Created by Vlad Maltsev on 29.12.2025.
//

extension Workflow where Self: TransitionProcess {
    public func start() async throws -> TransitionResult {
        .subflow(id)
    }
}
