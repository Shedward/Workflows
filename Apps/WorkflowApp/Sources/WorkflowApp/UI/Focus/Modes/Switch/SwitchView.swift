//
//  SwitchView.swift
//  WorkflowApp
//

import API
import SwiftUI

struct SwitchView: View {
    let viewModel: SwitchViewModel

    @Environment(\.theme) private var theme

    var body: some View {
        Group {
            if let error = viewModel.startError {
                DrawerMessage(text: error)
            } else {
                switch viewModel.state {
                    case .activeWorkflows:
                        LoadingView(viewModel.activeWorkflows) { workflows in
                            activeList(workflows)
                        }
                    case .newWorkflow:
                        LoadingView(viewModel.newWorkflows) { starts in
                            WorkflowPicker(starts: starts) { start in
                                viewModel.start(start)
                            }
                        }
                }
            }
        }
        .onAppear { viewModel.refresh() }
    }

    @ViewBuilder private func activeList(_ workflows: [WorkflowInstance]) -> some View {
        if workflows.isEmpty {
            DrawerMessage(text: "No running workflows")
        } else {
            ScrollView {
                ForEach(workflows) { workflow in
                    Button {
                        viewModel.activate(workflow)
                    } label: {
                        WorkflowCard(workflowInstance: workflow)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, theme.spacing.xl)
                }
            }
            .frame(maxHeight: 400)
            .contentMargins(.vertical, theme.spacing.xl, for: .scrollContent)
        }
    }
}
