//
//  SystemTheme.swift
//
//
//  Created by v.maltsev on 16.09.2023.
//

import SwiftUI

extension Theme {
    public static let system = Theme(
        colors: Colors(
            content: .init(
                primary: Color(.labelColor),
                secondary: Color(.secondaryLabelColor),
                tertiary: Color(.tertiaryLabelColor)
            ), 
            accessory: .init(
                primary: Color(.secondaryLabelColor),
                secondary: Color(.tertiaryLabelColor),
                tertiary: Color(.separatorColor)
            ),
            background: .init(
                primary: Color(.textBackgroundColor),
                secondary: Color(.controlBackgroundColor),
                tertiary: Color(.windowBackgroundColor)
            ),
            neutral: .primary,
            accent: .accentColor,
            positive: Color(.systemGreen),
            negative: Color(.systemRed),
            warning: Color(.systemOrange),
            special: Color(.systemPurple)
        ),
        fonts: Fonts(
            h1: .title,
            h2: .title2,
            h3: .title3,
            body: .body,
            caption: .caption,
            caption2: .caption2
        )
    )
}

#Preview {
    ThemePreview(theme: .system)
}
