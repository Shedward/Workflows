//
//  WorkflowCell.swift
//  WorkflowApp
//
//  Created by Мальцев Владислав on 02.04.2026.
//

import API
import SwiftUI

struct WorkflowCell: View {
    let workflow: Workflow

    var body: some View {
        VStack(alignment: .leading) {
            Text(workflow.id)
                .font(.headline)
        }
        .padding()
    }
}

#Preview {
    WorkflowCell(
        workflow: Workflow(
            id: "12345",
            stateId: [],
            transitions: []
        )
    )
}
