//
//  ThemePreview.swift
//
//
//  Created by v.maltsev on 16.09.2023.
//

import SwiftUI

struct ThemePreview: View {
    let theme: Theme

    var body: some View {
        HStack(alignment: .top) {
            ColorListPreview(
                theme: theme,
                colors: [
                     \.content.primary,
                     \.content.secondary,
                     \.content.tertiary,
                     \.background.primary,
                     \.background.secondary,
                     \.background.tertiary,
                     \.neutral,
                     \.accent,
                     \.positive,
                     \.negative,
                     \.warning,
                     \.special
                ]
            )

            FontListPreview(
                theme: theme,
                fonts: [
                     \.h1,
                     \.h2,
                     \.h3,
                     \.body,
                     \.caption,
                     \.caption2
                ]
            )
        }
        .padding()
    }
}

private struct ColorListPreview: View {
    let theme: Theme
    let colors: [ColorToken]

    var body: some View {
        VStack {
            Text("Colors")
                .font(.title)
            ForEach(colors.indices, id: \.self) { colorIndex in
                let colorToken = colors[colorIndex]
                let color = theme.color(for: colorToken)
                ColorPreview(name: String(describing: colorToken), color: color)
            }
        }
        .frame(maxWidth: 300)
    }
}

private struct ColorPreview: View {
    let name: String
    let color: Color

    var body: some View {
        HStack {
            Text(name)
            Spacer()
            Capsule()
                .foregroundStyle(color)
                .frame(width: 16, height: 8)
                .padding(4)
                .background(.background)
                .environment(\.colorScheme, .dark)
            Capsule()
                .foregroundStyle(color)
                .frame(width: 16, height: 8)
                .padding(4)
                .background(.background)
                .environment(\.colorScheme, .light)
        }
        .padding(4)
    }
}

private struct FontListPreview: View {
    let theme: Theme
    let fonts: [FontToken]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Fonts")
                .font(.title)
            ForEach(fonts.indices, id: \.self) { fontIndex in
                let fontToken = fonts[fontIndex]
                let font = theme.font(for: fontToken)
                Text(String(describing: fontToken))
                    .font(font)
            }
        }
        .frame(maxWidth: 300)
    }
}
