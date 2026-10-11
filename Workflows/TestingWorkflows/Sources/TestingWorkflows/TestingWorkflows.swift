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
    FlakyWorkflow(),
    BranchingWorkflow(),
    InitialDataWorkflow(),
    SlowWorkflow(),
    AutomaticSlowWorkflow(),
    SubflowDataFlowWorkflow(),
    ProvidedWorkflow(),
    ConditionBranchingWorkflow(),
    ConditionOutputWorkflow(),
    AskNameWorkflow(),
    AskWithDataWorkflow(),
    AutomaticLoopWorkflow(),
    CountingLoopWorkflow(),
    UnicodeIdWorkflow()
]
