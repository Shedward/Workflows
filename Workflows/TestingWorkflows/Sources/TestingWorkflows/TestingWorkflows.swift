//
//  TestingWorkflows.swift
//  TestingWorkflows
//
//  Created by Vlad Maltsev on 22.02.2026.
//

import WorkflowEngine

public let workflows: [any Workflow] = [
    TestWorkflow(),
    SimpleGitWorkflow()
]
