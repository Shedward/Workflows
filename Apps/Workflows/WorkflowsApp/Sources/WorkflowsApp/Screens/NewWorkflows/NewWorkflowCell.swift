//
//  NewWorkflowCell.swift
//
//
//  Created by Vlad Maltsev on 08.12.2023.
//

import SwiftUI
import UI
import Workflow

struct NewWorkflowCell: View {
    
    let description: NewWorkflowDescription
    
    var body: some View {
        SpacedHStack(alignment: .center) {
            Image(systemName: description.iconName)
            Text(description.name)
                .font(\.body)
                .lineLimit(2)
            Spacer()
            Image(systemName: "chevron.forward")
        }
        .contentShape(Rectangle())
        .spacing()
    }
}

#Preview {
    NewWorkflowCell(
        description: .init(
            id: "id",
            name: "Name name name",
            iconName: "suitcase"
        )
    )
}
