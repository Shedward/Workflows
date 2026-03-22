//
//  SlowAction.swift
//  TestingWorkflows
//
//  Created by Claude on 22.03.2026.
//

import Foundation
import WorkflowEngine

@DataBindable
struct SlowAction: Action {
    @Output var result: String

    func run() async throws {
        try await Task.sleep(for: .seconds(3))
        result = "Done"
    }
}
