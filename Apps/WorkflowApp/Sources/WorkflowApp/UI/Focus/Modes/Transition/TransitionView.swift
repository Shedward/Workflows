//
//  TransitionView.swift
//  WorkflowApp
//

import API
import SwiftUI

struct TransitionView: View {
    let focus: FocusViewModel
    let viewModel: TransitionViewModel

    @Environment(\.theme) private var theme

    var body: some View {
        Group {
            if let error = viewModel.error {
                errorRow(error)
            } else if viewModel.transitions.isEmpty {
                Text("No available transitions")
                    .themeFont(\.caption)
                    .themeColor(\.content.secondary)
                    .padding()
            } else {
                ScrollView {
                    ForEach(viewModel.transitions, id: \.processId) { transition in
                        row(for: transition)
                    }
                }
                .frame(maxHeight: 400)
                .contentMargins(.vertical, theme.spacing.xl, for: .scrollContent)
            }
        }
        .task(id: focus.activeWorkflow?.id) {
            viewModel.refresh()
        }
    }

    @ViewBuilder
    private func row(for transition: API.Transition) -> some View {
        Group {
            if viewModel.runningTransition?.processId == transition.processId {
                runningRow(for: transition)
            } else {
                idleRow(for: transition)
            }
        }
        .padding(.horizontal, theme.spacing.xl)
    }

    private func runningRow(for transition: API.Transition) -> some View {
        Card {
            HStack {
                ProgressView().controlSize(.small)
                Text(transition.trigger)
                    .themeFont(\.body)
                    .themeColor(\.content.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .transition(.opacity.combined(with: .scale))
    }

    private func idleRow(for transition: API.Transition) -> some View {
        Button {
            viewModel.take(transition)
        } label: {
            Card {
                VStack(alignment: .leading) {
                    Text(transition.trigger)
                        .themeFont(\.body)
                        .themeColor(\.content.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(transition.targets.joined(separator: ", "))
                        .themeFont(\.caption)
                        .themeColor(\.content.secondary)
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(viewModel.runningTransition != nil)
        .transition(.opacity.combined(with: .scale))
    }

    private func errorRow(_ message: String) -> some View {
        Text(message)
            .themeFont(\.caption)
            .themeColor(\.content.secondary)
            .padding()
    }
}
