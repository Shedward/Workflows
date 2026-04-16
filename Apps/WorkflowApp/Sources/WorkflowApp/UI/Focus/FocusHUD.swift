//
//  FocusHUD.swift
//  WorkflowApp
//
//  Created by Vlad Maltsev on 09.04.2026.
//

import SwiftUI

struct FocusHUD: View {
    @Environment(\.theme) private var theme
    @FocusState private var isFocused: Bool
    @State private var tint: Color?

    var content: AnyView = AnyView(WorkflowCard(workflowInstance: .Mock.decomposition))

    var body: some View {
        ZStack(alignment: .center) {
            let shape = RoundedRectangle(cornerSize: CGSize(width: 24, height: 24))
            content
                .onPreferableTintChange { tint = $0 }
                .padding()
                .glassEffect(.clear.tint((tint ?? .clear).opacity(0.10)), in: shape)
                .floatingShadow(in: shape)
                .transition(.blurReplace)
                .focusable()
                .focusEffectDisabled()
                .focused($isFocused)
                .onAppear { isFocused = true }
                .onKeyPress(.escape) {
                    FocusPresenter.shared.hide()
                    return .handled
                }
                .fixedSize()
                .movable()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    
}

#Preview {
    FocusHUD()
}
