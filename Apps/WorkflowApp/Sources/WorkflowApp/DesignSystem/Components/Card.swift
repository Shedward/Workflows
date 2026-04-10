//
//  Card.swift
//  WorkflowApp
//

import SwiftUI

struct Card<Content: View>: View {
    @Environment(\.theme) private var theme

    let tint: Color?
    @ViewBuilder let content: Content

    init(tint: Color? = nil, @ViewBuilder content: () -> Content) {
        self.tint = tint
        self.content = content()
    }

    private var borderHighlight: Color {
        if let tint {
            tint.opacity(0.3)
        } else {
            theme.colors.background.primary.opacity(0.3)
        }
    }

    private var borderShadow: Color {
        theme.colors.content.tertiary.opacity(0.3)
    }

    private var borderGradient: some ShapeStyle {
        LinearGradient(
            colors: [borderHighlight, borderShadow],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    var body: some View {
        content
            .themePadding(\.l)
            .background {
                RoundedRectangle(cornerRadius: theme.spacing.cornerRadius)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        if let tint {
                            RoundedRectangle(cornerRadius: theme.spacing.cornerRadius)
                                .fill(tint.opacity(0.1))
                        }
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: theme.spacing.cornerRadius)
                            .strokeBorder(
                                borderGradient,
                                lineWidth: 0.5
                            )
                    }
                    .shadow(color: theme.colors.content.tertiary.opacity(0.2), radius: 3, y: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: theme.spacing.cornerRadius))
    }
}
