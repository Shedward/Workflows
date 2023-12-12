//
//  AnyState.swift
//
//
//  Created by Vlad Maltsev on 10.12.2023.
//

public struct AnyState {
    public let id: String
    public let name: String
    public let transitions: [AnyWorkflowTransition]
    
    init(id: String, name: String, transitions: [AnyWorkflowTransition]) {
        self.id = id
        self.name = name
        self.transitions = transitions
    }
    
    init<S: State>(state: S, workflow: Workflow<S>) {
        self.init(
            id: state.description.id,
            name: state.description.name,
            transitions: state.description.transitions.map { transition in
                WorkflowTransition(workflow: workflow, transition: transition)
                    .asAny()
            }
        )
    }
}
