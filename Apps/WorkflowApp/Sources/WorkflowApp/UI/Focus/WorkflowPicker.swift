//
//  WorkflowPicker.swift
//  WorkflowApp
//

import API
import SwiftUI

struct WorkflowPicker: View {
    let starts: [WorkflowStart]
    let onSelect: (WorkflowStart) -> Void

    @Environment(\.theme) private var theme

    var body: some View {
        ScrollView {
            ForEach(starts) { start in
                Button {
                    onSelect(start)
                } label: {
                    Card(tint: start.workflowId.tint) {
                        VStack(alignment: .leading) {
                            Text(start.title ?? start.workflowId)
                                .themeFont(\.body)
                                .themeColor(\.content.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(start.workflowId)
                                .themeFont(\.caption)
                                .themeColor(\.content.secondary)
                        }
                    }
                }
                .buttonStyle(.plain)
                .padding(.horizontal, theme.spacing.xl)
            }
        }
        .frame(maxHeight: 400)
        .contentMargins(.vertical, theme.spacing.xl, for: .scrollContent)
    }
}

#Preview {
    FocusHUD {
        EmptyView()
    } content: {
        EmptyFocus {}
    } drawer: {
        WorkflowPicker(starts: WorkflowStart.Mock.all) { _ in }
    }
}
