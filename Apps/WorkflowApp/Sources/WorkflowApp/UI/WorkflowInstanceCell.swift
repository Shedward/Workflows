//
//  WorkflowInstanceCell.swift
//  WorkflowApp
//
//  Created by Мальцев Владислав on 02.04.2026.
//

import API
import SwiftUI

struct WorkflowInstanceCell: View {
    let instance: WorkflowInstance

    var body: some View {
        VStack(alignment: .leading) {
            Text(instance.workflowId)
                .font(.headline)
            Text(instance.state)
        }
        .padding()
    }
}

#Preview {
    WorkflowInstanceCell(
        instance: .Mock.decomposition
    )
}
