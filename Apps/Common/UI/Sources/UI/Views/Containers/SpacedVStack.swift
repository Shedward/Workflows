//
//  SpacedVStack.swift
//
//
//  Created by v.maltsev on 16.09.2023.
//

import SwiftUI

public struct SpacedVStack<Content: View>: View {

    @Environment(\.spacing)
    private var spacing: Spacing

    private let alignment: HorizontalAlignment
    private let content: () -> Content

    public init(
        alignment: HorizontalAlignment = .center,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.alignment = alignment
        self.content = content
    }

    public var body: some View {
        VStack(alignment: alignment, spacing: spacing.value) {
            content()
        }
    }
}

#Preview {
    Spaced(background: \.positive) {
        SpacedVStack {
            SpacedItemPreview()
            Spaced(background: \.negative) {
                SpacedVStack {
                    SpacedItemPreview()
                    SpacedItemPreview()
                    Spaced(background: \.special) {
                        SpacedVStack {
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
