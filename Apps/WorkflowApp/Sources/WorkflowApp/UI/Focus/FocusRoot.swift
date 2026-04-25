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
            case .empty, .selectingWorkflow, .failed:
                EmptyFocus(onStart: viewModel.startSelection)
            case .active(let instance):
                WorkflowCard(workflowInstance: instance)
            }
        } drawer: {
            if case .selectingWorkflow(let starts) = viewModel.state {
                WorkflowPicker(starts: starts) { start in
                    viewModel.select(start)
                }
            }
        }
    }
}
