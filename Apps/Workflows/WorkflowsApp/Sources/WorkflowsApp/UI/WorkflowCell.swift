//
//  WorkflowCell.swift
//
//
//  Created by v.maltsev on 04.09.2023.
//

import SwiftUI
import UI

struct WorkflowCell: View {
    let key: String
    let icon: Image
    let name: String
    let state: String

    @Environment(\.spacing)
    private var spacing: Spacing

    var body: some View {
        SpacedHStack(alignment: .top) {
            icon
                .foregroundColor(\.content.primary)
                .font(\.body)
            SpacedVStack(alignment: .leading) {
                SpacedHStack {
                    Text(key)
                        .foregroundColor(\.content.secondary)
                        .font(\.caption)
                    Spacer()
                    Text(state)
                        .foregroundColor(\.content.primary)
                        .font(\.caption)
                }
                Text(name)
                    .lineLimit(2)
                    .foregroundColor(\.content.primary)
                    .font(\.body)
            }
        }
        .spacedFrame(\.background.tertiary)
    }
}

#Preview {
    SpacedVStack {
        ForEach(0..<3) { _ in
            WorkflowCell(
                key: "PORTFOLIO-22623",
                icon: Image(systemName: "briefcase"),
                name: "Реализовать экран списка окна",
                state: "В работе"
            )
        }
    }
    .spacedFrame(\.background.primary)
    .spacing(.s1)
    .frame(maxWidth: 300)
}
