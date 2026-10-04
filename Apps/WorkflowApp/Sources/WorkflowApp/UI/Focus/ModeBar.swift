//
//  ModeBar.swift
//  WorkflowApp
//

import SwiftUI

struct ModeBar: View {
    let focus: FocusViewModel

    @Environment(\.theme) private var theme

    var body: some View {
        HStack(spacing: theme.spacing.s) {
            ForEach(FocusViewModel.modes) { descriptor in
                if let bar = descriptor.bar {
                    modeButton(id: descriptor.id, entry: bar)
                }
            }
            placeholderButton(systemImage: "doc.text")
        }
        .imageScale(.small)
        .opacity(0.5)
    }

    private func modeButton(id: FocusModeID, entry: ModeBarEntry) -> some View {
        Button {
            focus.enter(focus.currentMode == id ? .initial : id)
        } label: {
            Image(systemName: entry.icon)
                .opacity(focus.currentMode == id ? 1 : 0.7)
        }
        .keyboardShortcut(entry.shortcut, modifiers: .command)
        .buttonStyle(.plain)
    }

    private func placeholderButton(systemImage: String) -> some View {
        Image(systemName: systemImage)
            .opacity(0.5)
    }
}
