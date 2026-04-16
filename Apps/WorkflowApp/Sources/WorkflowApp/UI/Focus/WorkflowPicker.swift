//
//  WorkflowPicker.swift
//  WorkflowApp
//

import API
import SwiftUI

struct WorkflowPicker: View {
    let workflows: [Workflow]
    let onSelect: (Workflow) -> Void

    @Environment(\.theme) private var theme

    var body: some View {
        VStack(spacing: theme.spacing.s) {
            ForEach(workflows) { workflow in
                Button {
                    onSelect(workflow)
                } label: {
                    Card {
                        Text(workflow.id)
                            .themeFont(\.body)
                            .themeColor(\.content.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    FocusHUD {
        EmptyView()
    } content: {
        EmptyFocus {}
    } drawer: {
        WorkflowPicker(workflows: Workflow.Mock.all) { _ in }
    }
}
