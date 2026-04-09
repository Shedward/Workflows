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
    @FocusState private var isFocused: Bool

    var body: some View {
        Focus()
            .padding()
            .background(.ultraThinMaterial, in: .rect(cornerRadius: 14))
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
