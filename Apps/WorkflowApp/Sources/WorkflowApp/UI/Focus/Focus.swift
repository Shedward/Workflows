//
//  Focus.swift
//  WorkflowApp
//
//  Created by Мальцев Владислав on 09.04.2026.
//

import SwiftUI

struct Focus: View {
    @Environment(\.theme) private var theme

    var body: some View {
        Card(tint: theme.colors.warning) {
            HStack(alignment: .top, spacing: theme.spacing.xl) {
                Circle()
                    .fill(theme.colors.warning)
                    .frame(width: 8, height: 8)

                VStack(alignment: .leading, spacing: theme.spacing.s) {
                    Text("Deploy Pipeline")
                        .themeFont(\.title)
                        .themeColor(\.content.primary)

                    Text("waiting-approval")
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
