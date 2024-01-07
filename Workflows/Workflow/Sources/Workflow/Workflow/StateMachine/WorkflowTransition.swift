//
//  WorkflowTransition.swift
//
//
//  Created by Vlad Maltsev on 04.12.2023.
//

import Prelude

public struct WorkflowTransition<S: State>: Identifiable, CustomStringConvertible {
    
    public let workflow: Workflow<S>
    private let transition: AnyTransition<S>
    
    public var id: String {
        transition.id
    }
    
    public var name: String {
        transition.name
    }
    
    public init(workflow: Workflow<S>, transition: AnyTransition<S>) {
        self.workflow = workflow
        self.transition = transition
    }
    
    public var steps: TransitionSteps<S> {
        transition.steps
    }
    
    public var description: String {
        "WorkflowTransition<\(S.self)>(id: \(id))"
    }
}
