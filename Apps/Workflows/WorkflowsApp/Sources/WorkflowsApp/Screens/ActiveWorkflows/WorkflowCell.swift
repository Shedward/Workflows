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
import Prelude

struct WorkflowCell: View {
    
    let workflow: AnyWorkflow
    let onSelectTransition: (AnyWorkflowTransition) -> Void
    
    @SwiftUI.State
    private var state: AnyState?
    
    @Environment(\.dependencies)
    private var dependencies: AllDependencies
    
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
            
            if let state, isActive, let mainTransition = state.transitions.first {
                Divider()

                let otherTransitions = state.transitions.dropFirst()
                
                SpacedHStack {
                    Spacer()
                    Menu(mainTransition.name) {
                        ForEach(otherTransitions) { transition in
                            Button(transition.name) {
                                onSelectTransition(transition)
                            }
                        }
                    } primaryAction: {
                        onSelectTransition(mainTransition)
                    }
                    .buttonStyle(.bordered)
                    .scaledToFit()
                }
            }
        }
        .spacedFrame(
            \.background.tertiary,
             border: isActive ? stateAppearance.tintColor : \.accessory.tertiary
        )
        .spacing(.d2)
        .onReceive(workflow.statePublisher) { state in
            self.state = state
        }
    }
    
    init(workflow: AnyWorkflow, onSelectTransition: @escaping (AnyWorkflowTransition) -> Void) {
        self.workflow = workflow
        self.onSelectTransition = onSelectTransition
    }
}

#Preview {
    Group {
        WorkflowCell(
            workflow: HeadHunter.Mocks.portfolioWorkflow(
                name: "Long long description, to test how it's gonna looks when description is logn"
            ).asAny(),
            onSelectTransition: { _ in }
        )
        WorkflowCell(
            workflow: HeadHunter.Mocks.portfolioWorkflow().asAny(),
            onSelectTransition: { _ in }
        )
    }
    .spacing(.s1)
    .frame(width: 300)
    .padding()
    .backgroundColor(\.background.primary)
}
