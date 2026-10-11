//
//  WorkflowRunner+Retry.swift
//  WorkflowEngine
//

extension WorkflowRunner {
    /// Takes the failed transition recorded in the instance's `transitionState` again, with the
    /// data the instance had before it failed, and continues into the automatic chain on success.
    @discardableResult
    func retry(instanceId: WorkflowInstanceID) async throws -> WorkflowInstance {
        try await withInstanceLock(instanceId) { [self] in
            let instance = try await loadInstance(instanceId)
            guard
                case .failed = instance.transitionState?.state,
                let transitionId = instance.transitionState?.transitionId
            else {
                throw WorkflowsError.InstanceNotFailed(instanceId: instanceId)
            }
            guard let workflow = await registry.workflow(id: instance.workflowId) else {
                throw WorkflowsError.WorkflowNotFound(workflowId: instance.workflowId)
            }
            guard let transition = workflow.anyTransitions.first(where: { $0.id == transitionId }) else {
                throw WorkflowsError.TransitionProcessNotFoundForInstance(
                    instance: instanceId,
                    workflow: workflow.id,
                    transitionId: transitionId.processId,
                    availableTransitions: workflow.anyTransitions.filter { $0.from == instance.state }.map(\.id)
                )
            }
            return try await takeTransitionLocked(transition, on: instance, of: workflow)
        }
    }
}
