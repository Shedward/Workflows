//
//  ThemeColorModifier.swift
//  WorkflowApp
//

import SwiftUI

private struct ThemeForegroundColorModifier: ViewModifier {
    @Environment(\.theme) private var theme
    let keyPath: KeyPath<Colors, Color>

    func body(content: Content) -> some View {
        content.foregroundStyle(theme.colors[keyPath: keyPath])
    }
}

extension View {
    func themeColor(_ keyPath: KeyPath<Colors, Color>) -> some View {
        modifier(ThemeForegroundColorModifier(keyPath: keyPath))
    }
}

private struct ThemeBackgroundColorModifier: ViewModifier {
    @Environment(\.theme) private var theme
    let keyPath: KeyPath<Colors, Color>

    func body(content: Content) -> some View {
        content.background(theme.colors[keyPath: keyPath])
    }
}

extension View {
    func themeBackground(_ keyPath: KeyPath<Colors, Color>) -> some View {
        modifier(ThemeBackgroundColorModifier(keyPath: keyPath))
    }
}
