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

    public init(
        alignment: VerticalAlignment = .center,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.alignment = alignment
        self.content = content
    }

    public var body: some View {
        HStack(alignment: alignment, spacing: spacing.value) {
            content()
        }
    }
}

#Preview {
    Spaced(background: \.positive) {
        SpacedHStack {
            SpacedItemPreview()
            Spaced(background: \.negative) {
                SpacedHStack {
                    SpacedItemPreview()
                    SpacedItemPreview()
                    Spaced(background: \.special) {
                        SpacedHStack {
                            SpacedItemPreview()
                            SpacedItemPreview()
                            SpacedItemPreview()
                        }
                    }
                }
            }
            SpacedItemPreview()
            SpacedItemPreview()
        }
    }
}
