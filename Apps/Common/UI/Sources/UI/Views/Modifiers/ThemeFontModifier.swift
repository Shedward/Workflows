//
//  ThemeFontModifier.swift
//
//
//  Created by v.maltsev on 16.09.2023.
//

import SwiftUI

struct ThemeFontModifier: ViewModifier {

    @Environment(\.theme)
    var theme: Theme

    let fontToken: FontToken

    func body(content: Content) -> some View {
        content
            .font(theme.font(for: fontToken))
    }
}

public extension View {
    func themeFont(_ fontToken: FontToken) -> some View {
        modifier(ThemeFontModifier(fontToken: fontToken))
    }
}

#Preview {
    Text("Hello, world!")
        .backgroundStyle(ThemeColor(\.accent))
        .themeFont(\.h2)
        .theme(.system)
}
