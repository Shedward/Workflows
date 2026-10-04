//
//  FocusRoot.swift
//  WorkflowApp
//

import SwiftUI

struct FocusRoot: View {
    let viewModel: FocusViewModel

    @Environment(\.theme) private var theme

    private var currentMode: AnyFocusMode {
        switch viewModel.currentMode {
            case .initial:
                AnyFocusMode(InitMode(focus: viewModel))
            case .switching:
                AnyFocusMode(SwitchMode(focus: viewModel))
            case .transition:
                AnyFocusMode(TransitionMode(focus: viewModel))
        }
    }

    var body: some View {
        let mode = currentMode
        FocusHUD {
            VStack(spacing: theme.spacing.s) {
                ModeBar(focus: viewModel)
                mode.roof
            }
        } content: {
            mode.content
        } drawer: {
            mode.drawer
        }
        .onKeyPress(.escape) {
            if viewModel.currentMode == .initial {
                FocusPresenter.shared.hide()
            } else {
                viewModel.enter(.initial)
            }
            return .handled
        }
    }
}
