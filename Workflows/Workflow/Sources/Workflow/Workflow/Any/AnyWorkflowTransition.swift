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
    private let getRunner: () -> AnyTransitionRunner
    private let getWorkflow: () -> AnyWorkflow
    
    public init<S: State>(_ wrapped: WorkflowTransition<S>) {
        self.getId = { wrapped.id }
        self.getName = { wrapped.name }
        self.getRunner = { TransitionRunner(steps: wrapped.steps, workflow: wrapped.workflow) }
        self.getWorkflow = { wrapped.workflow.asAny() }
    }
    
    public init(
        id: String,
        name: String,
        run: AnyTransitionRun = AnyTransitionRun(
            totalProgress: ProgressGroup(),
            steps: { }
        ),
        workflow: AnyWorkflow = AnyWorkflow()
    ) {
        self.getId = { id }
        self.getName = { name }
        self.getRunner = { MockTransitionRunner(run: run) }
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
    
    public func runner() -> AnyTransitionRunner {
        getRunner()
    }
}

extension WorkflowTransition {
    func asAny() -> AnyWorkflowTransition {
        AnyWorkflowTransition(self)
    }
}
