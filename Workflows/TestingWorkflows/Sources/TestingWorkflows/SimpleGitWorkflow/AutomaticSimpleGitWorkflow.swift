//
//  AutomaticSimpleGitWorkflow.swift
//  TestingWorkflows
//
//  Created by Vlad Maltsev on 23.02.2026.
//

import WorkflowEngine

@DataBindable
struct AutomaticSimpleGitWorkflow: Workflow {
    enum State: String, WorkflowState {
        case workingDirectoryCreated
        case repositoryCreated
        case readmeCreated
        case allCommited
    }

    var transitions: Transitions {
        chainedAfterStart {
            CreateTempWorkingDirectory.to(.workingDirectoryCreated)
            InitialiseRepository.to(.repositoryCreated)
            WriteReadmeFile.to(.readmeCreated)
            CommitChanges.to(.allCommited)
            CleanWorkingFolder.toFinish()
        }
    }
}
