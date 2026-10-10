import Foundation
import Testing
@testable import WorkflowEngine

@Suite("Workflows: resume after restart")
struct WorkflowsResumeTests {
    let directory = FileManager.default.temporaryDirectory.appending(path: "WorkflowsResumeTests-\(UUID().uuidString)")

    private func restartedWorkflows() async throws -> Workflows {
        try await Workflows(
            storage: JSONFileWorkflowStorage(directory: directory),
            dependencies: DependenciesContainer()
        ) {
            ResumableWorkflow()
        }
    }

    private func persist(_ instance: WorkflowInstance) async throws {
        let storage = try await JSONFileWorkflowStorage(directory: directory)
        try await storage.update(instance)
    }

    private func parked(id: String, workflowId: String = "ResumableWorkflow", version: Int = 1) -> WorkflowInstance {
        WorkflowInstance(
            id: id,
            workflowId: workflowId,
            workflowVersion: version,
            state: "parked",
            transitionState: nil,
            data: WorkflowData()
        )
    }

    @Test func anInterruptedAutomaticChainContinues() async throws {
        try await persist(parked(id: "interrupted"))

        let workflows = try await restartedWorkflows()
        try await workflows.run()

        #expect(try await workflows.instance(id: "interrupted").state == "done")
    }

    @Test func anInstanceOfAnUnregisteredWorkflowIsSkippedAndKept() async throws {
        try await persist(parked(id: "orphan", workflowId: "Nowhere"))
        try await persist(parked(id: "interrupted"))

        let workflows = try await restartedWorkflows()
        try await workflows.run()

        #expect(try await workflows.instance(id: "orphan").state == "parked")
        #expect(try await workflows.instance(id: "interrupted").state == "done")
    }

    @Test func anInstanceOfAnotherVersionIsSkippedAndKept() async throws {
        try await persist(parked(id: "stale", version: 2))

        let workflows = try await restartedWorkflows()
        try await workflows.run()

        #expect(try await workflows.instance(id: "stale").state == "parked")
    }
}
