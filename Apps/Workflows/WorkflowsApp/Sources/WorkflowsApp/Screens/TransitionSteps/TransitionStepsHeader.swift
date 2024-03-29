//
//  TransitionStepsHeader.swift
//
//
//  Created by Vlad Maltsev on 07.01.2024.
//

import SwiftUI
import Workflow
import UI
import Prelude

struct TransitionStepsHeader: View {
    
    let workflow: AnyWorkflow
    let transition: AnyWorkflowTransition
    let onTapRun: () -> Void

    let progressState: ProgressState
    
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
                switch progressState.state {
                case .notStarted, .failed:
                    if progressState.state == .failed {
                        SpacedHStack(spacing: .d1) {
                            Text(Localized.number(progressState.messages.count))
                            Image(systemName: "exclamationmark.circle.fill")
                        }
                        .foregroundColor(\.negative)
                        .font(\.body)
                        .bold()
                    }
                    Spacer()
                    Button(action: onTapRun) {
                        Text(transition.name)
                    }
                    .buttonStyle(.borderedProminent)
                case .inProgress, .finished:
                    ProgressView(value: progressState.value)
                }
            }
        }
        .spacedFrame(\.background.tertiary, border: \.accessory.tertiary, borderWidth: 1.0)
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
        progressState: .finished
    )
}
