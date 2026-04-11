//
//  Focus.swift
//  WorkflowApp
//
//  Created by Мальцев Владислав on 09.04.2026.
//

import SwiftUI

struct Focus: View {
    var tint: Color?

    @Environment(\.theme) private var theme

    var body: some View {
        Card(tint: tint) {
            HStack(alignment: .top, spacing: theme.spacing.xl) {
                Circle()
                    .fill(tint ?? theme.colors.accent)
                    .frame(width: 8, height: 8)

                VStack(alignment: .leading, spacing: theme.spacing.s) {
                    Text("Декомпозиция_портфеля")
                        .themeFont(\.title)
                        .themeColor(\.content.primary)

                    Text("ждем_встречи_по_декомпозиции")
                        .themeFont(\.mono)
                        .themeColor(\.content.secondary)
                }

                Spacer(minLength: 0)
            }
        }
    }
}

#Preview {
    FocusHUD()
}
