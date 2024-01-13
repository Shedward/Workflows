//
//  TransitionSteps.swift
//
//
//  Created by Vlad Maltsev on 02.01.2024.
//

import Prelude
import Foundation

public struct TransitionSteps<S: State> {
    public let build: (TransitionRunContext<S>) -> [TransitionStep]
    
    public init(@ArrayBuilder<TransitionStep> build: @escaping (_ run: TransitionRunContext<S>) -> [TransitionStep]) {
        self.build = build
    }
    
    public init(_ action: @escaping (_ ctx: TransitionRunContext<S>, _ progress: Prelude.Progress) async throws -> Void) {
        self.build = { run in
            [
                TransitionStep(id: "1.Action", name: nil) { progress in
                    try await action(run, progress)
                }
            ]
        }
    }
}
