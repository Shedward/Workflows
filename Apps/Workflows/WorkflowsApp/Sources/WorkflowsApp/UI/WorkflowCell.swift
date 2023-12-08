//
//  WorkflowCell.swift
//
//
//  Created by v.maltsev on 04.09.2023.
//

import SwiftUI
import UI
import Workflow

struct WorkflowCell: View {
    
    let details: WorkflowDetails
    
    var body: some View {
        SpacedVStack(alignment: .leading) {
            Text(details.type.id)
                .font(\.caption)
                .bold()
            Text(details.name)
                .font(\.body)
        }
    }
}

struct DepWorkflowCell: View {
    let key: String
    let icon: Image
    let statusIcon: Image?
    let name: String
    let state: String
    
    @Environment(\.spacing)
    private var spacing: Spacing
    
    var body: some View {
        SpacedHStack(alignment: .top) {
            SpacedVStack {
                icon
                    .foregroundColor(\.content.primary)
                    .font(\.body)
                statusIcon
            }
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
            VStack {
                Image(systemName: "chevron.compact.right")
                    .foregroundColor(\.accessory.primary)
            }
        }
        .spacedFrame(\.background.tertiary)
    }
}

#Preview {
    WorkflowCell(
        details: WorkflowDetails(
            id: WorkflowId(name: "Test"),
            type: WorkflowType("PreviewType"),
            name: "Preview name"
        )
    )
    .spacing(.d2)
}

#Preview {
    SpacedVStack {
        ForEach(0..<1) { _ in
            DepWorkflowCell(
                key: "MOB-22623",
                icon: Image(systemName: "briefcase"), 
                statusIcon: nil,
                name: "Реализовать экран списка окна с длинным названием",
                state: "В работе"
            )
        }
        .spacing(.d1)

        SpacedVStack {
            ForEach(0..<2) { _ in
                DepWorkflowCell(
                    key: "MOB-22623",
                    icon: Image(systemName: "checkmark.rectangle"),
                    statusIcon: nil,
                    name: "Реализовать экран списка окна с длинным названием",
                    state: "В работе"
                )
            }
        }
        .spacedFrame(\.background.tertiary)
        .spacing(.d2)
    }
    .spacedFrame(\.background.primary)
    .frame(maxWidth: 300)
}
