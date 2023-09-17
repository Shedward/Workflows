//
//  ThemeBackgroundColorModifier.swift
//
//
//  Created by v.maltsev on 17.09.2023.
//

import SwiftUI

struct ThemeBackgroundColorModifier: ViewModifier {

    @Environment(\.theme)
    var theme: Theme

    let colorToken: ColorToken

    func body(content: Content) -> some View {
        content.backgroundStyle(theme.color(for: colorToken))
    }
}

public extension View {
    func backgroundThemeColor(
        _ colorToken: ColorToken
    ) -> some View {
        modifier(ThemeBackgroundColorModifier(colorToken: colorToken))
    }
}

#Preview {
    Spaced(background: \.accent) {
        Spaced(background: \.background.tertiary) {
            Spaced(background: \.background.secondary) {
                Spaced(background: \.background.primary) {
                    Rectangle()
                        .frame(width: 64, height: 64)
                        .foregroundThemeColor(\.accent)
                }
            }
        }
    }
}
