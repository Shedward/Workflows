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
    private let relativeSpacing: RelativeSpacing

    public init(
        spacing: RelativeSpacing = .same,
        alignment: HorizontalAlignment = .center,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.relativeSpacing = spacing
        self.alignment = alignment
        self.content = content
    }

    public var body: some View {
        VStack(alignment: alignment, spacing: spacing.relative(relativeSpacing).value) {
            content()
        }
    }
}
