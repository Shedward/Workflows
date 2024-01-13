//
//  TransitionContext.swift
//
//
//  Created by Vlad Maltsev on 13.01.2024.
//

public struct TransitionRunContext<S: State> {
    public let workflow: Workflow<S>
    public let promises: TransitionPromises
    
    public init(workflow: Workflow<S>, promises: TransitionPromises) {
        self.workflow = workflow
        self.promises = promises
    }
}
