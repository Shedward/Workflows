//
//  TransitionSteps.swift
//
//
//  Created by Vlad Maltsev on 02.01.2024.
//

import Prelude
import Foundation

public struct TransitionSteps<S: State> {
    public let steps: (Workflow<S>) -> [TransitionStep]
    
    public init(@ArrayBuilder<TransitionStep> steps: @escaping (Workflow<S>) -> [TransitionStep]) {
        self.steps = steps
    }
    
    public init(_ action: @escaping (_ workflow: Workflow<S>, _ progres: Prelude.Progress) async throws -> Void) {
        self.steps = { workflow in
            [
                TransitionStep(id: "1.Action", name: nil) { progres in
                    try await action(workflow, progres)
                }
            ]
        }
    }
}
