//
//  WorkflowContext.swift
//  Workflow
//
//  Created by Vlad Maltsev on 30.12.2025.
//

public struct WorkflowContext: Sendable {
    var instance: WorkflowInstance
    var routedTarget: StateID?
    let resume: ResumeReason?
    let dependencies: DependenciesContainer
    let startSubflow: @Sendable (_ workflow: AnyWorkflow, _ initialData: WorkflowData) async throws -> WorkflowInstance
}

enum ResumeReason {
    case time
    case workflowFinished(data: WorkflowData)
    case answered(data: WorkflowData)

    /// A late answer or timer must not resume a transition that is waiting for something else.
    func resumes(_ state: TransitionState.State?) -> Bool {
        switch (self, state) {
            case (.time, .waiting(.time)), (.workflowFinished, .waiting(.workflowFinished)), (.answered, .waiting(.asking)):
                true
            default:
                false
        }
    }
}
