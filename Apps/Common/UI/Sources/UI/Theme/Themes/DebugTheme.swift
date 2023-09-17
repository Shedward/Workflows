//
//  DebugTheme.swift
//
//
//  Created by v.maltsev on 16.09.2023.
//

import SwiftUI

extension Theme {
    public static let debug = Theme(
        colors: Colors(
            content: ColorsByLevel(
                primary: Color(.blue),
                secondary: Color(.blue.withAlphaComponent(0.5)),
                tertiary: Color(.blue.withAlphaComponent(0.25))
            ),
            background: ColorsByLevel(
                primary: Color(.orange),
                secondary: Color(.orange.withAlphaComponent(0.5)),
                tertiary: Color(.orange.withAlphaComponent(0.25))
            ),
            neutral: Color(.red),
            accent: Color(.purple),
            positive: Color(.yellow),
            negative: Color(.yellow.withAlphaComponent(0.5)),
            warning: Color(.yellow.withAlphaComponent(0.35)),
            special: Color(.yellow.withAlphaComponent(0.25))
        ),
        fonts: Fonts(
            h1: .system(size: 13).bold(),
            h2: .system(size: 12).bold(),
            h3: .system(size: 11).bold(),
            body: .system(size: 11).italic(),
            caption: .system(size: 8),
            caption2: .system(size: 8)
        )
    )
}

#Preview {
    ThemePreview(theme: .debug)
}
