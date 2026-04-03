//
//  WorkflowStartProvider.swift
//  WorkflowEngine
//
//  Created by Claude on 03.04.2026.
//

public protocol WorkflowStartProvider: DataBindable, Sendable {
    func starting() async throws -> [WorkflowStart]
}
