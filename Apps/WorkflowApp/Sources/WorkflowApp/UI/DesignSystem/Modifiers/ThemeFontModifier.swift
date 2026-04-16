//
//  ThemeFontModifier.swift
//  WorkflowApp
//

import SwiftUI

private struct ThemeFontModifier: ViewModifier {
    @Environment(\.theme) private var theme
    let keyPath: KeyPath<Fonts, Font>

    func body(content: Content) -> some View {
        content.font(theme.fonts[keyPath: keyPath])
    }
}

extension View {
    func themeFont(_ keyPath: KeyPath<Fonts, Font>) -> some View {
        modifier(ThemeFontModifier(keyPath: keyPath))
    }
}
