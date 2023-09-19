//
//  SpacedRelativelyModifier.swift
//
//
//  Created by v.maltsev on 19.09.2023.
//

import SwiftUI

struct SpacedRelativelyModifier: ViewModifier {
    
    @Environment(\.spacing)
    private var spacing: Spacing

    let relative: RelativeSpacing

    func body(content: Content) -> some View {
        content
            .environment(\.spacing, spacing.relative(relative))
    }
}

extension View {
    public func spacing(_ relative: RelativeSpacing = .d1) -> some View {
        modifier(SpacedRelativelyModifier(relative: relative))
    }
}
