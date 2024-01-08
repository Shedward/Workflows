//
//  AnyTransitionStepsAction.swift
//
//
//  Created by Vlad Maltsev on 07.01.2024.
//

import Prelude

public final class AnyTransitionSteps {

    public let totalProgress: ProgressProtocol
    public let steps: [AnyTransitionStep]
    private let callAsFunctionAction: () async throws -> Void
    
    init<S: State>(_ wrapped: TransitionSteps<S>, progressGroup: ProgressGroup, workflow: Workflow<S>) {
        self.totalProgress = progressGroup
        
        let transitionSteps = wrapped.steps(workflow)
        let stepFraction = 1.0 / Float(max(transitionSteps.count, 1))
            
        let steps = transitionSteps.map { step in
            let stepProgress = progressGroup.progress(fraction: stepFraction)
            return AnyTransitionStep(
                id: step.id,
                name: step.name ?? workflow.details.name ?? step.id,
                progress: stepProgress
            ) {
                stepProgress.state = .started
                do {
                    try await step(stepProgress)
                    stepProgress.state = .finished
                } catch {
                    stepProgress.state = .failed(error)
                    throw error
                }
            }
        }
        
        self.steps = steps
        self.callAsFunctionAction = {
            for step in steps {
                try await step.action()
            }
        }
    }
    
    public init(totalProgress: ProgressProtocol, @ArrayBuilder<AnyTransitionStep> steps: () -> [AnyTransitionStep]) {
        self.totalProgress = totalProgress
        self.steps = steps()
        self.callAsFunctionAction = { }
    }
    
    public func callAsFunction() async throws {
        try await callAsFunctionAction()
    }
}
