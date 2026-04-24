//
//  EmptyFocus.swift
//  WorkflowApp
//

import SwiftUI

struct EmptyFocus: View {
    let title: String
    let subtitle: String
    let onStart: () -> Void

    @Environment(\.theme) private var theme

    init(
        title: String = "No active workflows",
        subtitle: String = "Press to start",
        onStart: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.onStart = onStart
    }

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
                            Text(title)
                                .themeFont(\.headline)
                                .themeColor(\.content.primary)
                        }

                        Text(subtitle)
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
