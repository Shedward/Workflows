//
//  NewWorkflowCell.swift
//
//
//  Created by Vlad Maltsev on 08.12.2023.
//

import SwiftUI
import UI
import Workflow
import HeadHunter

struct NewWorkflowCell: View {

    @Environment(\.dependencies)
    private var dependencies: AllDependencies
    
    let description: NewWorkflowDescription
    
    var body: some View {
        SpacedVStack(alignment: .leading) {
            SpacedHStack {
                let stateAppearance = dependencies.workflowTypeAppearance.appearance(for: description.type)
                stateAppearance.icon
                Text(description.key ?? stateAppearance.name)
                Spacer()
                Image(systemName: "chevron.compact.right")
            }
            .font(\.caption)
            .bold()
            
            Text(description.name ?? "")
                .font(\.body)
        }
        .spacedFrame(\.background.tertiary, border: \.accessory.tertiary)
        .spacing(.d2)
    }
}

#Preview {
    NewWorkflowCell(
        description: .init(
            id: "id", 
            key: "WORK-001",
            name: "Name name name",
            type: WorkflowType(PortfolioState.self)
        )
    )
}
