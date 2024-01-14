//
//  TransitionRunner.swift
//
//
//  Created by Vlad Maltsev on 13.01.2024.
//

import Foundation
import Prelude

public protocol AnyTransitionRunner {
    func run(totalProgress: ProgressGroup) -> AnyTransitionRun
}

public final class TransitionRunner<S: State>: AnyTransitionRunner {
    
    private let steps: TransitionSteps<S>
    private let workflow: Workflow<S>
    private let promises = TransitionPromises()
    
    public init(steps: TransitionSteps<S>, workflow: Workflow<S>) {
        self.steps = steps
        self.workflow = workflow
    }

    public func run(totalProgress: ProgressGroup) -> AnyTransitionRun {
        let run = TransitionRunContext(workflow: workflow, promises: promises)
        let transitionSteps = steps.build(run)
        let stepFraction = 1.0 / Float(max(transitionSteps.count, 1))
        
        let anySteps = transitionSteps.map { step in
            let stepProgress = totalProgress.progress(fraction: stepFraction)
            return AnyTransitionStep(
                id: step.id,
                name: step.name,
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
        
        return AnyTransitionRun(
            id: UUID().uuidString,
            totalProgress: totalProgress,
            steps: anySteps
        ) {
            for step in anySteps {
                try await step.action()
            }
        }
    }
}

public final class MockTransitionRunner: AnyTransitionRunner {
    
    private let run: AnyTransitionRun
    
    public init(run: AnyTransitionRun) {
        self.run = run
    }
    
    public func run(totalProgress: ProgressGroup) -> AnyTransitionRun {
        run
    }
}
