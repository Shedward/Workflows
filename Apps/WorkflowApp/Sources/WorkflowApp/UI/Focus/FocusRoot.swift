//
//  FocusRoot.swift
//  WorkflowApp
//

import SwiftUI

struct FocusRoot: View {
    @State var viewModel: FocusViewModel

    var body: some View {
        FocusHUD {
            EmptyView()
        } content: {
            switch viewModel.state {
            case .empty, .selectingWorkflow:
                EmptyFocus(onStart: viewModel.startSelection)
            case .active(let instance):
                WorkflowCard(workflowInstance: instance)
            }
        } drawer: {
            if case .selectingWorkflow(let workflows) = viewModel.state {
                WorkflowList(workflows: workflows) { workflow in
                    viewModel.select(workflow: workflow)
                }
            }
        }
    }
}
