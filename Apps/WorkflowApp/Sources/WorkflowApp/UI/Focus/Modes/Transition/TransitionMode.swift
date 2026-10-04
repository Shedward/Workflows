//
//  TransitionMode.swift
//  WorkflowApp
//

import SwiftUI

struct TransitionMode: FocusMode {
    let focus: FocusViewModel

    private var viewModel: TransitionViewModel { focus.transitionVM }

    var roof: some View {
        EmptyView()
    }

    var content: some View {
        ActiveWorkflowContent(focus: focus, emptyFallback: .switching)
    }

    var drawer: some View {
        TransitionView(focus: focus, viewModel: viewModel)
    }
}
