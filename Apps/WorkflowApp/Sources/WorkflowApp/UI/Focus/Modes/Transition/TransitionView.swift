//
//  TransitionView.swift
//  WorkflowApp
//

import API
import SwiftUI

struct TransitionView: View {
    let viewModel: TransitionViewModel

    @Environment(\.theme) private var theme
    @State private var tappedProcessId: String?

    var body: some View {
        Group {
            if let error = viewModel.taking.error {
                DrawerMessage(text: error.localizedDescription)
            } else {
                LoadingView(viewModel.transitions) { transitions in
                    if transitions.isEmpty {
                        DrawerMessage(text: "No available transitions")
                    } else {
                        ScrollView {
                            ForEach(transitions, id: \.processId) { transition in
                                row(for: transition)
                            }
                        }
                        .frame(maxHeight: 400)
                        .contentMargins(.vertical, theme.spacing.xl, for: .scrollContent)
                        .animation(.snappy, value: viewModel.taking.isRunning)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func row(for transition: API.Transition) -> some View {
        Group {
            if viewModel.taking.isRunning, tappedProcessId == transition.processId {
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
            tappedProcessId = transition.processId
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
        .disabled(viewModel.taking.isRunning)
        .transition(.opacity.combined(with: .scale))
    }
}
