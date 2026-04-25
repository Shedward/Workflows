//
//  SwitchMode.swift
//  WorkflowApp
//

import SwiftUI

struct SwitchMode: FocusMode {
    let focus: FocusViewModel

    private var viewModel: SwitchViewModel { focus.switchVM }

    var roof: some View {
        SwitchRoof(viewModel: viewModel)
    }

    var content: some View {
        ActiveWorkflowContent(focus: focus, emptyFallback: .initial)
    }

    var drawer: some View {
        SwitchView(viewModel: viewModel)
    }
}

private struct SwitchRoof: View {
    let viewModel: SwitchViewModel

    var body: some View {
        Button {
            switch viewModel.state {
                case .activeWorkflows:
                    viewModel.showNewWorkflow()
                case .newWorkflow:
                    viewModel.showActiveWorkflows()
            }
        } label: {
            Card {
                Text(label)
                    .themeFont(\.body)
                    .themeColor(\.content.primary)
                    .frame(maxWidth: .infinity)
            }
        }
        .buttonStyle(.plain)
    }

    private var label: String {
        switch viewModel.state {
            case .activeWorkflows:
                "<New>"
            case .newWorkflow:
                "<Back>"
        }
    }
}
