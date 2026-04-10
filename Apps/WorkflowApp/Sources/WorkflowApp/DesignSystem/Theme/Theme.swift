//
//  Theme.swift
//  WorkflowApp
//

import SwiftUI

struct Theme {
    let colors: Colors
    let fonts: Fonts
    let spacing: Spacing
}

extension Theme {
    static let system = Theme(
        colors: .system,
        fonts: .system,
        spacing: .default
    )
}

private struct ThemeEnvironmentKey: EnvironmentKey {
    static let defaultValue = Theme.system
}

extension EnvironmentValues {
    var theme: Theme {
        get { self[ThemeEnvironmentKey.self] }
        set { self[ThemeEnvironmentKey.self] = newValue }
    }
}

extension View {
    func theme(_ theme: Theme) -> some View {
        environment(\.theme, theme)
    }
}
