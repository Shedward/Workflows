//
//  Wait.swift
//  Workflow
//
//  Created by Vlad Maltsev on 29.12.2025.
//

import Foundation

public protocol Wait: TransitionProcess {
    func resume() async throws -> Waiting.Time?
}

extension Wait where Self: TransitionProcess {
    public func start(context: WorkflowContext) async throws -> TransitionResult {
        let nextTime = try await resume()
        if let nextTime {
            return .waiting(.time(nextTime))
        } else {
            return .completed
        }
    }
}
