//
//  ActiveWorkflowContent.swift
//  WorkflowApp
//

import SwiftUI

/// The `content` slot shared by every mode: the active workflow card if set,
/// otherwise an EmptyFocus placeholder that routes the user to a fallback mode.
struct ActiveWorkflowContent: View {
    let focus: FocusViewModel
    let emptyFallback: FocusModeID

    var body: some View {
        if let activeWorkflow = focus.activeWorkflow {
            WorkflowCard(workflowInstance: activeWorkflow)
        } else {
            EmptyFocus { focus.enter(emptyFallback) }
        }
    }
}
