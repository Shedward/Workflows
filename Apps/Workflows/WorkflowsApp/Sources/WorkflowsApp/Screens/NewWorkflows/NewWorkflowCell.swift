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
            SpacedVStack {
                if let key = description.key {
                    Text(key)
                        .font(\.caption)
                }
                if let name = description.name {
                    Text(name)
                        .font(\.body)
                        .lineLimit(2)
                }
            }
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
            key: "WORK-001",
            name: "Name name name",
            iconName: "suitcase"
        )
    )
}
