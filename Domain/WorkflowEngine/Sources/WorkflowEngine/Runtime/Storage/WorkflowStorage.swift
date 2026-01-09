//
//  WorkflowStorage.swift
//  Workflow
//
//  Created by Vlad Maltsev on 26.12.2025.
//

public protocol WorkflowStorage: Sendable {
    func create(_ workflow: AnyWorkflow, initialData: WorkflowData) async throws -> WorkflowInstance
    func update(_ instance: WorkflowInstance) async throws
    func finish(_ instance: WorkflowInstance) async throws

    func all() async throws -> [WorkflowInstance]
    func instance(id: WorkflowInstanceID) async throws -> WorkflowInstance?
}
