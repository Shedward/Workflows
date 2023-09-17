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

    func body(content: Content) -> some View {
        content
            .padding(edges, spacing.value)
    }
}

public extension View {
    func spacedPadding(_ edges: Edge.Set = .all) -> some View {
        modifier(SpacedPaddingModifier(edges: edges))
    }
}

#Preview {
    Text("Hello, world!")
        .spacedPadding()
}
