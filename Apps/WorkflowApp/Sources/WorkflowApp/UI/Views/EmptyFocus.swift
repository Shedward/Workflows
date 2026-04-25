//
//  EmptyFocus.swift
//  WorkflowApp
//

import SwiftUI

struct EmptyFocus: View {
    let onStart: () -> Void

    @Environment(\.theme) private var theme

    init(
        onStart: @escaping () -> Void
    ) {
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
                        Text("No active workflows")
                            .themeFont(\.headline)
                            .themeColor(\.content.primary)

                        Text("Press to start")
                            .themeFont(\.caption)
                            .themeColor(\.content.secondary)
                    }
                    .padding(.horizontal, theme.spacing.l)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    FocusHUD {
        EmptyView()
    } content: {
        EmptyFocus {}
    } drawer: {
        EmptyView()
    }
}
