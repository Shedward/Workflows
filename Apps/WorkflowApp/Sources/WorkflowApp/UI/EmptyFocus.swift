//
//  EmptyFocus.swift
//  WorkflowApp
//

import SwiftUI

struct EmptyFocus: View {
    let onStart: () -> Void

    @Environment(\.theme) private var theme

    var body: some View {
        Button {
            onStart()
        } label: {
            Card {
                HStack(alignment: .center, spacing: .zero) {
                    Image(systemName: "zzz")
                        .themeFont(\.large)
                    VStack(alignment: .leading, spacing: theme.spacing.s) {
                        HStack {
                            Text("No active workflows")
                                .themeFont(\.title)
                                .themeColor(\.content.primary)
                        }

                        Text("Press to start")
                            .themeFont(\.caption)
                            .themeColor(\.content.secondary)
                    }
                    .padding(.horizontal, theme.spacing.l)
                }
            }
        }
        .buttonStyle(.plain)
        .keyboardShortcut("N")
    }
}

#Preview {
    FocusHUD {
        Text("⌥ N")
    } content: {
        EmptyFocus {}
    } drawer: {
        EmptyView()
    }
}
