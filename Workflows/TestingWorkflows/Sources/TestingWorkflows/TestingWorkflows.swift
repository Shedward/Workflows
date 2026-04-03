//
//  TestingWorkflows.swift
//  TestingWorkflows
//
//  Created by Vlad Maltsev on 22.02.2026.
//

import WorkflowEngine

public let workflows: [any Workflow] = [
    SimpleWorkflow(),
    SimpleGitWorkflow(),
    AutomaticSimpleGitWorkflow(),
    WaitingWorkflow(),
    SubflowsWorkflow(),
    AutomaticSubflowsWorkflow(),
    FailingWorkflow(),
    BranchingWorkflow(),
    InitialDataWorkflow(),
    SlowWorkflow(),
    AutomaticSlowWorkflow(),
    SubflowDataFlowWorkflow(),
    ProvidedWorkflow()
]

public let invalidWorkflows: [any Workflow] = [
    UnreachableFinishWorkflow(),
    UnreachableStateWorkflow(),
    AutomaticCycleWorkflow(),
    AmbiguousAutomaticWorkflow(),
    UndeclaredInputWorkflow(),
    UndeclaredOutputWorkflow(),
    ConditionalInputWorkflow(),
    TypeMismatchWorkflow(),
    UnusedInputWorkflow(),
    MissingDependencyWorkflow(),
    UnsatisfiedSubflowInputWorkflow(),
    CircularAlpha()
]
