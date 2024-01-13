//
//  AnyTransitionStepsAction.swift
//
//
//  Created by Vlad Maltsev on 07.01.2024.
//

import Prelude

public struct AnyTransitionRun {

    public let totalProgress: ProgressProtocol
    public let steps: [AnyTransitionStep]
    private let callAsFunctionAction: () async throws -> Void
    
    public init(
        totalProgress: ProgressProtocol,
        steps: [AnyTransitionStep],
        callAsFunctionAction: @escaping () async throws -> Void
    ) {
        self.totalProgress = totalProgress
        self.steps = steps
        self.callAsFunctionAction = callAsFunctionAction
    }
    
    public init(
        totalProgress: ProgressProtocol,
        @ArrayBuilder<AnyTransitionStep> steps: () -> [AnyTransitionStep]
    ) {
        self.totalProgress = totalProgress
        self.steps = steps()
        self.callAsFunctionAction = { }
    }
    
    public func callAsFunction() async throws {
        try await callAsFunctionAction()
    }
}
