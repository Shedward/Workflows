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

    let background: ColorToken

    func body(content: Content) -> some View {
        content
            .padding(spacing.value)
            .backgroundColor(background)
            .clipShape(RoundedRectangle(cornerRadius: spacing.relative(.d1).value))
    }
}

extension View {
    public func spacedFrame(_ background: ColorToken) -> some View {
        modifier(SpacedFrameModifier(background: background))
    }
}

#Preview {
    Text("Hello frame")
        .border(Color.blue)
        .spacedFrame(\.background.tertiary)
        .spacedFrame(\.background.primary)
        .padding()
}
