//
//  AutomaticSimpleGitWorkflow.swift
//  TestingWorkflows
//
//  Created by Vlad Maltsev on 23.02.2026.
//

import WorkflowEngine

struct AutomaticSimpleGitWorkflow: Workflow {
    enum State: String, WorkflowState {
        static let initial = State.begin
        static let final = State.end

        case begin
        case workingDirectoryCreated
        case repositoryCreated
        case readmeCreated
        case allCommited
        case end
    }

    public var transitions: Transitions {
        after {
            CreateTempWorkingDirectory.to(.workingDirectoryCreated)
            InitialiseRepository.to(.repositoryCreated)
            WriteReadmeFile.to(.readmeCreated)
            CommitChanges.to(.allCommited)
            CleanWorkingFolder.toFinish()
        }
    }
}
