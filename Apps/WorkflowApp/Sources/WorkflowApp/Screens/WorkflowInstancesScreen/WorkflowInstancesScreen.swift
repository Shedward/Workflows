//
//  WorkflowInstancesScreen.swift
//  WorkflowApp
//
//  Created by Мальцев Владислав on 02.04.2026.
//

import SwiftUI
import API

struct WorkflowInstancesScreen: View {

    @State
    private var workflowInstances: [WorkflowInstance]?

    @Environment(\.workflowService)
    var workflowsService

    var body: some View {
        List(workflowInstances ?? []) { instance in
            WorkflowInstanceCell(instance: instance)
        }
        .task {
            workflowInstances = try? await workflowsService?.getWorkflowInstances() ?? []
        }
    }
}

