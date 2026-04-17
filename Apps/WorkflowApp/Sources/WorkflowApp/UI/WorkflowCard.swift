//
//  WorkflowCard.swift
//  WorkflowApp
//
//  Created by Мальцев Владислав on 09.04.2026.
//

import API
import SwiftUI

struct WorkflowCard: View {
    let workflowInstance: WorkflowInstance

    @Environment(\.theme) private var theme

    var body: some View {
        Card(tint: workflowInstance.workflowId.tint) {
            HStack(alignment: .firstTextBaseline, spacing: theme.spacing.xl) {
                Circle()
                    .fill(workflowInstance.tint)
                    .frame(width: theme.spacing.m, height: theme.spacing.m)

                VStack(alignment: .leading, spacing: theme.spacing.s) {
                    HStack {
                        Text(workflowInstance.workflowId)
                            .themeFont(\.title)
                            .themeColor(\.content.primary)
                    }

                    Text(workflowInstance.state)
                        .themeFont(\.mono)
                        .themeColor(\.content.secondary)
                }
                .padding(.trailing, theme.spacing.xl)
            }
        }
        .preferableTint(workflowInstance.tint)
    }
}

#Preview {
    WorkflowCard(
        workflowInstance: .Mock.decomposition
    )
}
