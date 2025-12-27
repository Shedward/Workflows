//
//  Action+TransitionProcess.swift
//  Workflow
//
//  Created by Vlad Maltsev on 27.12.2025.
//

public extension Action where Self: TransitionProcess {
    func start() async throws -> TransitionResult {
        try await run()
        return .completed
    }
}
