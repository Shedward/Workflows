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
            if let error = viewModel.error {
                errorRow(error)
            } else {
                switch viewModel.state {
                    case .activeWorkflows:
                        activeList
                    case .newWorkflow:
                        WorkflowPicker(starts: viewModel.newWorkflows) { start in
                            viewModel.start(start)
                        }
                }
            }
        }
        .onAppear { viewModel.refresh() }
    }

    @ViewBuilder private var activeList: some View {
        if viewModel.activeWorkflows.isEmpty {
            Text("No running workflows")
                .themeFont(\.caption)
                .themeColor(\.content.secondary)
                .padding()
        } else {
            ScrollView {
                ForEach(viewModel.activeWorkflows) { workflow in
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

    private func errorRow(_ message: String) -> some View {
        Text(message)
            .themeFont(\.caption)
            .themeColor(\.content.secondary)
            .padding()
    }
}
