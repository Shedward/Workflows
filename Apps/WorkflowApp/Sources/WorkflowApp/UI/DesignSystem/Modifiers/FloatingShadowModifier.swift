//
//  FloatingShadowModifier.swift
//  WorkflowApp
//

import SwiftUI

private struct FloatingShadowModifier<S: InsettableShape>: ViewModifier {
    @Environment(\.theme) private var theme

    let shape: S

    private var borderGradient: LinearGradient {
        LinearGradient(
            colors: [
                theme.colors.content.tertiary.opacity(0.6),
                theme.colors.content.tertiary.opacity(0.25)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    func body(content: Content) -> some View {
        content
            .overlay {
                shape.strokeBorder(borderGradient, lineWidth: 0.5)
            }
            .shadow(
                color: theme.colors.content.tertiary.opacity(0.35),
                radius: 24,
                y: 10
            )
            .shadow(
                color: theme.colors.content.tertiary.opacity(0.15),
                radius: 4,
                y: 2
            )
    }
}

extension View {
    func floatingShadow(in shape: some InsettableShape) -> some View {
        modifier(FloatingShadowModifier(shape: shape))
    }
}
