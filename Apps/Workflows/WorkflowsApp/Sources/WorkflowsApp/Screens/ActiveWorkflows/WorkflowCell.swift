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
        .frame(maxWidth: .infinity)
        .spacedFrame(\.background.tertiary)
        .spacing()
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
