//
//  SimpleGitWorkflow.swift
//  TestingWorkflows
//
//  Created by Vlad Maltsev on 22.02.2026.
//

import WorkflowEngine

struct SimpleGitWorkflow: Workflow {
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
        on(.begin) {
            CreateTempWorkingDirectory.to(.workingDirectoryCreated)
        }

        on(.workingDirectoryCreated) {
            InitialiseRepository.to(.repositoryCreated)
        }

        on(.repositoryCreated) {
            WriteReadmeFile.to(.readmeCreated)
        }

        on(.readmeCreated) {
            CommitChanges.to(.allCommited)
        }

        on(.allCommited) {
            CleanWorkingFolder.toFinish()
        }
    }
}
