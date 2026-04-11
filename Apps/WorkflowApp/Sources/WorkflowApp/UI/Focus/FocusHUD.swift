//
//  FocusHUD.swift
//  WorkflowApp
//
//  Created by Vlad Maltsev on 09.04.2026.
//

import SwiftUI

/// Spotlight-style chrome around `Focus`. Hosted inside `FocusPresenter`'s
/// `NSPanel`. Auto-takes focus on appear so Escape works on the very first
/// keystroke.
struct FocusHUD: View {
    @Environment(\.theme) private var theme
    @FocusState private var isFocused: Bool

    var body: some View {
        Focus(tint: .green)
            .padding()
            .glassEffect(.clear.tint(theme.colors.dimmed), in: .rect(cornerSize: CGSize(width: 24, height: 24)))
            .transition(.blurReplace)
            .focusable()
            .focusEffectDisabled()
            .focused($isFocused)
            .onAppear { isFocused = true }
            .onKeyPress(.escape) {
                FocusPresenter.shared.hide()
                return .handled
            }
    }
}

#Preview {
    FocusHUD()
}
