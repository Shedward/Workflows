//
//  TrayMenu.swift
//  WorkflowApp
//
//  Created by Vlad Maltsev on 09.04.2026.
//

import SwiftUI

struct TrayMenu: View {
    private let presenter = FocusPresenter.shared

    var body: some View {
        Button(presenter.isVisible ? "Hide" : "Show") {
            presenter.toggle()
        }
        Divider()
        Button("Quit") {
            NSApp.terminate(nil)
        }
        .keyboardShortcut("q")
    }
}
