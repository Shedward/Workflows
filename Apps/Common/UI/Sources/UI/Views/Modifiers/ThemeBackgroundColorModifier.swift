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
        content
            .background()
            .backgroundStyle(theme.color(for: colorToken))
    }
}

public extension View {
    func backgroundColor(
        _ colorToken: ColorToken
    ) -> some View {
        modifier(ThemeBackgroundColorModifier(colorToken: colorToken))
    }
}

#Preview {
    Text("Hello")
        .frame(width: 64, height: 64)
        .backgroundColor(\.accent)
}
