//
//  AnyTransitionStepsAction.swift
//
//
//  Created by Vlad Maltsev on 07.01.2024.
//

import Prelude
import Foundation

public struct AnyTransitionRun {

    public let id: String
    public let totalProgress: ProgressProtocol
    public let steps: [AnyTransitionStep]
    private let callAsFunctionAction: () async throws -> Void
    
    public init(
        id: String,
        totalProgress: ProgressProtocol,
        steps: [AnyTransitionStep],
        callAsFunctionAction: @escaping () async throws -> Void
    ) {
        self.id = id
        self.totalProgress = totalProgress
        self.steps = steps
        self.callAsFunctionAction = callAsFunctionAction
    }
    
    public init(
        id: String = UUID().uuidString,
        totalProgress: ProgressProtocol,
        @ArrayBuilder<AnyTransitionStep> steps: () -> [AnyTransitionStep]
    ) {
        self.id = id
        self.totalProgress = totalProgress
        self.steps = steps()
        self.callAsFunctionAction = { }
    }
    
    public func callAsFunction() async throws {
        try await callAsFunctionAction()
    }
}
