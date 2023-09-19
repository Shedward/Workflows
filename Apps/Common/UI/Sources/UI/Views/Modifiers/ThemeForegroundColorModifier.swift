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
    func foregroundColor(_ colorToken: ColorToken) -> some View {
        modifier(ThemeForegroundColorModifier(colorToken: colorToken))
    }
}

#Preview {
    VStack {
        Text("Accent")
            .foregroundColor(\.accent)
        Text("Positive")
            .foregroundColor(\.positive)
        Text("Negative")
            .foregroundColor(\.negative)
    }
    .padding()
}
