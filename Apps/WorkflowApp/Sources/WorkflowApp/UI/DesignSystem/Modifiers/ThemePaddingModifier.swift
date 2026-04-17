//
//  ThemePaddingModifier.swift
//  WorkflowApp
//

import SwiftUI

private struct ThemePaddingModifier: ViewModifier {
    @Environment(\.theme) private var theme
    let keyPath: KeyPath<Spacing, CGFloat>
    let edges: Edge.Set

    func body(content: Content) -> some View {
        content.padding(edges, theme.spacing[keyPath: keyPath])
    }
}

extension View {
    func themePadding(_ keyPath: KeyPath<Spacing, CGFloat>, _ edges: Edge.Set = .all) -> some View {
        modifier(ThemePaddingModifier(keyPath: keyPath, edges: edges))
    }
}
