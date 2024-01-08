//
//  SpacedFrameModifier.swift
//
//
//  Created by v.maltsev on 19.09.2023.
//

import SwiftUI

struct SpacedFrameModifier: ViewModifier {
    
    @Environment(\.spacing)
    private var spacing: Spacing
    
    @Environment(\.theme)
    private var theme: Theme

    let background: ColorToken
    let border: ColorToken?
    let borderWidth: CGFloat

    func body(content: Content) -> some View {
        content
            .padding(spacing.value)
            .backgroundColor(background)
            .clipShape(shape)
            .overlay {
                if let border {
                    shape.stroke(theme.color(for: border), lineWidth: borderWidth)
                } else {
                    Color.clear
                }
            }
    }
    
    private var shape: some Shape {
        RoundedRectangle(cornerRadius: spacing.relative(.d1).value)
    }
}

extension View {
    public func spacedFrame(
        _ background: ColorToken,
        border: ColorToken? = nil,
        borderWidth: CGFloat = 1
    ) -> some View {
        modifier(
            SpacedFrameModifier(
                background: background,
                border: border,
                borderWidth: borderWidth
            )
        )
    }
}

#Preview {
    Text("Hello frame")
        .border(Color.blue)
        .spacedFrame(\.background.tertiary)
        .padding()
}
