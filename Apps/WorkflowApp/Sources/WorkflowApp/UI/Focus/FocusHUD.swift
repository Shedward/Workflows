//
//  FocusHUD.swift
//  WorkflowApp
//
//  Created by Vlad Maltsev on 09.04.2026.
//

import SwiftUI

struct FocusHUD<Roof: View, Content: View, Drawer: View>: View {
    @Environment(\.theme) private var theme
    @FocusState private var isFocused: Bool
    @State private var tint: Color?
    private let presenter = FocusPresenter.shared

    @ViewBuilder var roof: Roof
    @ViewBuilder var content: Content
    @ViewBuilder var drawer: Drawer

    var body: some View {
        ZStack(alignment: .center) {
            let shape = RoundedRectangle(cornerSize: CGSize(width: 24, height: 24))
            VStack(spacing: theme.spacing.m) {
                roof
                content
                    .onPreferableTintChange { tint = $0 }
                    .padding()
                    .glassEffect(.clear.tint((tint ?? .clear).opacity(0.10)), in: shape)
                    .floatingShadow(in: shape)
                    .transition(.blurReplace)
                drawer
                    .clipped()
                    .floatingShadow(in: shape)
            }
            .focusable()
            .focusEffectDisabled()
            .focused($isFocused)
            .onChange(of: presenter.isVisible) { _, isVisible in
                if isVisible { isFocused = true }
            }
            .onKeyPress(.escape) {
                presenter.hide()
                return .handled
            }
            .fixedSize()
            .movable()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview("Content only") {
    FocusHUD {
        EmptyView()
    } content: {
        WorkflowCard(workflowInstance: .Mock.decomposition)
    } drawer: {
        VStack {
            Button("One") {}
            Text("Two")
        }
        .padding()
    }
}

#Preview("Empty state") {
    FocusHUD {
        EmptyView()
    } content: {
        EmptyFocus {}
    } drawer: {
        EmptyView()
    }
}
