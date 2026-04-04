//
//  ManualProvider.swift
//  WorkflowEngine
//
//  Created by Claude on 03.04.2026.
//

@DataBindable
public struct ManualProvider: WorkflowStartProvider {
    public init() {}

    public func starting() async -> [WorkflowStart] {
        [.manual]
    }
}
