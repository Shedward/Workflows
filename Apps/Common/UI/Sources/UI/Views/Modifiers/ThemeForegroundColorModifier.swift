//
//  ThemeForegroundColorModifier.swift
//
//
//  Created by v.maltsev on 16.09.2023.
//

import SwiftUI

struct ThemeForegroundColorModifier: ViewModifier {

    @Environment(\.theme)
    var theme: Theme

    let colorToken: ColorToken

    func body(content: Content) -> some View {
        content.foregroundStyle(theme.color(for: colorToken))
    }
}

public extension View {
    func foregroundThemeColor(_ colorToken: ColorToken) -> some View {
        modifier(ThemeForegroundColorModifier(colorToken: colorToken))
    }
}

#Preview {
    VStack {
        Text("Accent")
            .foregroundThemeColor(\.accent)
        Text("Positive")
            .foregroundThemeColor(\.positive)
        Text("Negative")
            .foregroundThemeColor(\.negative)
    }
    .padding()
}
