//
//  WorkflowList.swift
//  WorkflowApp
//
//  Created by Мальцев Владислав on 02.04.2026.
//

import API
import SwiftUI

struct WorkflowList: View {

    @State
    private var workflows: [Workflow]?

    @Environment(\.workflowService)
    var workflowsService

    var body: some View {
        List(workflows ?? []) { workflow in
            WorkflowCell(workflow: workflow)
        }
        .task {
            workflows = try? await workflowsService?.getWorkflows() ?? []
        }
    }
}
