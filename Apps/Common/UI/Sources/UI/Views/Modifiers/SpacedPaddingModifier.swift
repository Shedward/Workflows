//
//  SpacedPaddingModifier.swift
//
//
//  Created by v.maltsev on 16.09.2023.
//

import SwiftUI

struct SpacedPaddingModifier: ViewModifier {

    @Environment(\.spacing)
    private var spacing: Spacing

    let edges: Edge.Set
    let relative: RelativeSpacing

    func body(content: Content) -> some View {
        content
            .padding(edges, spacing.relative(relative).value)
    }
}

public extension View {
    func spacedPadding(_ edges: Edge.Set = .all, relative: RelativeSpacing = .same) -> some View {
        modifier(SpacedPaddingModifier(edges: edges, relative: relative))
    }
}

#Preview {
    Text("Hello, world!")
        .border(Color.blue)
        .spacedPadding()
        .border(Color.red)
}
