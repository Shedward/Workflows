//
//  WorkflowRunner+Resume.swift
//  WorkflowEngine
//

import Core
import os

extension WorkflowRunner {
    /// Picks persisted instances up after a restart: waits are rescheduled and interrupted automatic
    /// chains continue. An instance whose workflow is not registered, or is registered with another
    /// version, is skipped with a log line and stays in storage untouched.
    func resume() async throws {
        let instances = try await storage.all()
        var resumable: [WorkflowInstance] = []
        for instance in instances {
            if let reason = await reasonNotToResume(instance) {
                logger?.warning("Skipping instance \(instance.id, privacy: .public): \(reason, privacy: .public)")
            } else {
                resumable.append(instance)
            }
        }

        logger?.trace("Resume runner (\(resumable.count) of \(instances.count) instances)")
        await scheduler.rebuild(from: resumable)
        for instance in resumable {
            await runAutomaticTransitions(from: instance)
        }
    }

    private func reasonNotToResume(_ instance: WorkflowInstance) async -> String? {
        guard let workflow = await registry.workflow(instance: instance) else {
            return "workflow '\(instance.workflowId)' is not registered"
        }
        guard instance.workflowVersion == workflow.version else {
            return "'\(instance.workflowId)' is version \(instance.workflowVersion), registered is \(workflow.version)"
        }
        return nil
    }
}
