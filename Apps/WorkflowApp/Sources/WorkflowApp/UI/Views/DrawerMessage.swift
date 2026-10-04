//
//  DrawerMessage.swift
//  WorkflowApp
//

import SwiftUI

struct DrawerMessage: View {
    let text: String

    var body: some View {
        Text(text)
            .themeFont(\.caption)
            .themeColor(\.content.secondary)
            .padding()
    }
}
