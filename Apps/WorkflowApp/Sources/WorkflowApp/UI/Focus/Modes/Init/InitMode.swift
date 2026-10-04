//
//  InitMode.swift
//  WorkflowApp
//

import SwiftUI

struct InitMode: FocusMode {
    let focus: FocusViewModel

    var roof: some View {
        EmptyView()
    }

    var content: some View {
        ActiveWorkflowContent(focus: focus, emptyFallback: .switching)
    }

    var drawer: some View {
        EmptyView()
    }
}
