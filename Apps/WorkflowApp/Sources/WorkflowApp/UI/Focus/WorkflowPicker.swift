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
        ScrollView {
            ForEach(workflows) { workflow in
                Button {
                    onSelect(workflow)
                } label: {
                    Card(tint: workflow.tint) {
                        Text(workflow.id)
                            .themeFont(\.body)
                            .themeColor(\.content.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxHeight: 400)
        .contentMargins(theme.spacing.xl, for: .scrollContent)
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
