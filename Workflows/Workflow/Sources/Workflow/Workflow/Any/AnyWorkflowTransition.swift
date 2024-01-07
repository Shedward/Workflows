//
//  AnyWorkflowTransition.swift
//
//
//  Created by Vlad Maltsev on 06.12.2023.
//

import Prelude
import Foundation

public struct AnyWorkflowTransition: Identifiable {
    
    private let getId: () -> String
    private let getName: () -> String
    private let getSteps: (ProgressGroup) -> AnyTransitionSteps
    private let getWorkflow: () -> AnyWorkflow
    
    public init<S: State>(_ wrapped: WorkflowTransition<S>) {
        self.getId = { wrapped.id }
        self.getName = { wrapped.name }
        self.getSteps = { AnyTransitionSteps(wrapped.steps, progressGroup: $0, workflow: wrapped.workflow) }
        self.getWorkflow = { wrapped.workflow.asAny() }
    }
    
    public init(
        id: String,
        name: String,
        steps: AnyTransitionSteps = AnyTransitionSteps(totalProgress: Prelude.Progress(), steps: { }),
        workflow: AnyWorkflow = AnyWorkflow()
    ) {
        self.getId = { id }
        self.getName = { name }
        self.getSteps = { _ in steps }
        self.getWorkflow = { workflow }
    }
    
    public var id: String {
        getId()
    }
    
    public var name: String {
        getName()
    }
    
    public var workflow: AnyWorkflow {
        getWorkflow()
    }
    
    public func steps(progress: ProgressGroup) -> AnyTransitionSteps {
        getSteps(progress)
    }
}

extension WorkflowTransition {
    func asAny() -> AnyWorkflowTransition {
        AnyWorkflowTransition(self)
    }
}
