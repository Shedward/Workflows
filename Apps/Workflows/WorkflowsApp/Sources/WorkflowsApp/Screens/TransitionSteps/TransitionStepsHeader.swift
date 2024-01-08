//
//  TransitionStepsHeader.swift
//
//
//  Created by Vlad Maltsev on 07.01.2024.
//

import SwiftUI
import Workflow
import UI

struct TransitionStepsHeader: View {
    
    let workflow: AnyWorkflow
    let transition: AnyWorkflowTransition
    let onTapRun: () -> Void

    var isLoading: Bool
    
    @Environment(\.dependencies)
    private var dependencies: AllDependencies
    
    @SwiftUI.State
    private var state: AnyState?
    
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

            Text(workflow.details.name ?? "")
                .font(\.body)
            
            SpacedHStack {
                Spacer()
                Button(action: onTapRun) {
                    Text(transition.name)
                }
                .buttonStyle(.borderedProminent)
                .disabled(isLoading)
            }
        }
        .spacedFrame(\.background.tertiary, border: \.accent)
        .spacing()
        .onReceive(workflow.statePublisher) { state in
            self.state = state
        }
    }
}

#Preview {
    TransitionStepsHeader(
        workflow: AnyWorkflow(),
        transition: AnyWorkflowTransition(id: "mock", name: "Mock"),
        onTapRun: { },
        isLoading: true
    )
}
