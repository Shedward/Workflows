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
    
    let newWorkflow: AnyNewWorkflow
    
    var body: some View {
        SpacedHStack(alignment: .center) {
            Text(newWorkflow.name)
                .font(\.body)
                .lineLimit(2)
                .bold()
            Spacer()
            Image(systemName: "chevron.forward")
        }
    }
}
