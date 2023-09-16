//
//  Group.swift
//
//
//  Created by v.maltsev on 16.09.2023.
//

import SwiftUI

public struct Spaced<Content: View>: View {
    
    @Environment(\.spacing)
    private var spacing: Spacing

    @Environment(\.theme)
    private var theme: Theme

    private let background: ColorToken?
    private let withoutPadding: Bool
    private let content: () -> Content

    public init(
        background: ColorToken? = nil,
        withoutPadding: Bool = false,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.background = background
        self.withoutPadding = withoutPadding
        self.content = content
    }

    public var body: some View {
        content()
            .padding(withoutPadding ? .zero : spacing.value)
            .iflet(background) { background, view in
                view
                    .background(theme.color(for: background))
                    .clipShape(RoundedRectangle(cornerRadius: spacing.down().value))
            }
            .spacing(spacing.down())
    }
}

#Preview {
    Spaced(background: \.background.primary) {
        Spaced(background: \.background.tertiary) {
            Spaced(background: \.background.secondary) {
                Spaced(background: \.negative) {
                    Spaced(background: \.positive) {
                        Text("Hello")
                            .background(Color(.systemGray))
                    }
                }
            }
        }
    }
}
