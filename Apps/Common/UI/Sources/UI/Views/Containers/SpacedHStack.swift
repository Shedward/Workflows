//
//  SpacedHStack.swift
//
//
//  Created by v.maltsev on 16.09.2023.
//

import SwiftUI

public struct SpacedHStack<Content: View>: View {

    @Environment(\.spacing)
    private var spacing: Spacing

    private let alignment: VerticalAlignment
    private let content: () -> Content
    private let relativeSpacing: RelativeSpacing

    public init(
        spacing: RelativeSpacing = .same,
        alignment: VerticalAlignment = .center,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.relativeSpacing = spacing
        self.alignment = alignment
        self.content = content
    }

    public var body: some View {
        HStack(
            alignment: alignment,
            spacing: spacing.relative(relativeSpacing).value
        ) {
            content()
        }
    }
}

#Preview {
    SpacedHStack {
        SpacedItemPreview()
        SpacedItemPreview()
        SpacedItemPreview()
    }
    .spacedFrame(\.positive)
}
