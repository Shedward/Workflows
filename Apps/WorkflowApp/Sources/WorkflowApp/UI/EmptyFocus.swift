//
//  EmptyFocus.swift
//  WorkflowApp
//
//  Created by Мальцев Владислав on 16.04.2026.
//

import SwiftUI


struct EmptyFocus: View {
    var body: some View {
        Label("Start", systemImage: "play")
    }
}

#Preview {
    FocusHUD(content: AnyView(EmptyFocus()))
}

