//
//  FocusRoot.swift
//  WorkflowApp
//

import SwiftUI

struct FocusRoot: View {
    let viewModel: FocusViewModel

    var body: some View {
        FocusHUD {
            EmptyView()
        } content: {
            switch viewModel.state {
            case .empty, .selectingWorkflow:
                EmptyFocus(onStart: viewModel.startSelection)
            case .active(let instance):
                WorkflowCard(workflowInstance: instance)
            case .failed(let message):
                EmptyFocus(
                    title: "Couldn't reach server",
                    subtitle: message,
                    onStart: viewModel.startSelection
                )
            }
        } drawer: {
            if case .selectingWorkflow(let workflows) = viewModel.state {
                WorkflowPicker(workflows: workflows) { workflow in
                    viewModel.select(workflow: workflow)
                }
            }
        }
    }
}
