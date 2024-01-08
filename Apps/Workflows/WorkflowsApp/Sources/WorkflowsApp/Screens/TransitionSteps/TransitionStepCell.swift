//
//  TransitionStepCell.swift
//
//
//  Created by Vlad Maltsev on 07.01.2024.
//

import SwiftUI
import UI
import Workflow
import Prelude

struct TransitionStepCell: View {
    let transitionStep: AnyTransitionStep
    
    @SwiftUI.State
    private var progressState: ProgressState
    
    init(transitionStep: AnyTransitionStep) {
        self.transitionStep = transitionStep
        _progressState = .init(initialValue: transitionStep.progress.state)
    }
    
    var body: some View {
        SpacedVStack(alignment: .leading) {
            SpacedHStack {
                progressIcon
                    .frame(width: 24, height: 24)
                Text(transitionStep.name)
                    .font(\.body)
                Spacer()
            }
            .font(\.body)
            .bold()
            
            if let message = progressState.message {
                Divider()
                Text(message)
                    .font(\.caption)
                    .foregroundColor(progressState.state == .failed ? \.negative : \.content.primary)
            }
        }
        .id(transitionStep.id)
        .onReceive(transitionStep.progress.publisher) { progressState in
            self.progressState = progressState
        }
        .frame(maxWidth: .infinity)
        .spacedFrame(\.background.tertiary, border: progressState.state == .failed ? \.negative : nil)
        .spacing()
    }

    @ViewBuilder
    private var progressIcon: some View {
        switch progressState.state {
        case .notStarted:
            Image(systemName: "circle")
        case .inProgress:
            ProgressView()
                .scaleEffect(0.5)
        case .finished:
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(\.positive)
        case .failed:
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(\.negative)
        }
    }
}

#Preview {
    TransitionStepCell(
        transitionStep: AnyTransitionStep(
            id: "mock",
            name: "Name",
            progress: Prelude.Progress(state: .finished),
            action: { }
        )
    )
    .spacing(.s3)
}
