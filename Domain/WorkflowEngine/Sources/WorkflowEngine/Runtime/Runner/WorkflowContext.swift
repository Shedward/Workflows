//
//  WorkflowContext.swift
//  Workflow
//
//  Created by Vlad Maltsev on 30.12.2025.
//

public struct WorkflowContext: Sendable {
    var instance: WorkflowInstance
    let resume: WaitScheduler.ResumeReason?
    let dependancyContainer: DependenciesContainer
    let start: @Sendable (_ workflow: AnyWorkflow, _ initialData: WorkflowData) async throws -> WorkflowInstance
}
