//
//  WorkflowCell.swift
//
//
//  Created by v.maltsev on 04.09.2023.
//

import SwiftUI
import UI
import Workflow
import HeadHunter

struct WorkflowCell: View {
    
    @Environment(\.dependencies)
    private var dependencies: AllDependencies
    
    let workflow: AnyWorkflow
    
    init(workflow: AnyWorkflow) {
        self.workflow = workflow
    }
    
    @SwiftUI.State
    private var state: AnyState?
    
    private var isActive: Bool {
        dependencies.activeWorkflowService.isActive(workflow)
    }
    
    var body: some View {
        let stateAppearance = dependencies
            .workflowTypeAppearance.appearance(for: workflow.details.type)
        
        SpacedVStack(alignment: .leading) {
            SpacedHStack {
                stateAppearance.icon
                Text(workflow.details.key ?? stateAppearance.name)
                
                Spacer()
                Text(state?.name ?? "")
                Image(systemName: "chevron.compact.right")
            }
            .font(\.caption)
            .bold()
            
            if isActive {
                Divider()
            }
            
            Text(workflow.details.name ?? "")
                .font(\.body)
            
            if isActive {
                Divider()
                
                SpacedHStack {
                    Spacer()
                    Button("На ревью") {}
                }
            }
        }
        .spacedFrame(
            \.background.tertiary ,
             border: isActive ? stateAppearance.tintColor : \.accessory.tertiary
        )
        .spacing(.d2)
        .task {
            state = await workflow.state()
        }
    }
}

#Preview {
    Group {
        WorkflowCell(
            workflow: HeadHunter.Mocks.portfolioWorkflow(
                name: "Long long description, to test how it's gonna looks when description is logn"
            ).asAny()
        )
        WorkflowCell(
            workflow: HeadHunter.Mocks.portfolioWorkflow().asAny()
        )
    }
    .spacing(.s1)
    .frame(width: 300)
    .padding()
    .backgroundColor(\.background.primary)
}
