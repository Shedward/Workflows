//
//  AutomaticSimpleGitWorkflow.swift
//  TestingWorkflows
//
//  Created by Vlad Maltsev on 23.02.2026.
//

import WorkflowEngine

struct AutomaticSimpleGitWorkflow: Workflow {
    enum State: String, WorkflowState {
        case workingDirectoryCreated
        case repositoryCreated
        case readmeCreated
        case allCommited
    }

    public var transitions: Transitions {
        afterStart {
            CreateTempWorkingDirectory.to(.workingDirectoryCreated)
            InitialiseRepository.to(.repositoryCreated)
            WriteReadmeFile.to(.readmeCreated)
            CommitChanges.to(.allCommited)
            CleanWorkingFolder.toFinish()
        }
    }
}
