//
//  ManualProvider.swift
//  WorkflowEngine
//
//  Created by Claude on 03.04.2026.
//

@DataBindable
struct ManualProvider: WorkflowStartProvider {
    func starting() async -> [WorkflowStart] {
        [.manual]
    }
}
