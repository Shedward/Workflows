//
//  EmptyFocus.swift
//  WorkflowApp
//

import SwiftUI

struct EmptyFocus: View {
    var onStart: () -> Void

    var body: some View {
        Button(action: onStart) {
            Label("Start", systemImage: "play")
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    FocusHUD {
        EmptyView()
    } content: {
        EmptyFocus {}
    } drawer: {
        EmptyView()
    }
}
