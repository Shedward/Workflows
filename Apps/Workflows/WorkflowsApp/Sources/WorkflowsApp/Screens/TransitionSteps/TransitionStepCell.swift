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
        SpacedHStack {
            progressIcon
            Text(transitionStep.name)
            Spacer()
        }
        .font(\.body)
        .bold()
        .id(transitionStep.id)
        .onReceive(transitionStep.progress.publisher) { progressState in
            self.progressState = progressState
        }
        .frame(maxWidth: .infinity)
        .spacedFrame(\.background.tertiary)
    }
    
    @ViewBuilder
    private var progressIcon: some View {
        switch progressState {
        case.initial:
            Image(systemName: "circle")
        case .finished:
            Image(systemName: "checkmark.circle.fill")
        default:
            switch progressState.style {
            case .normal:
                Image(systemName: "bolt.circle")
            case .failed:
                Image(systemName: "exclamationmark.circle.fill")
            }
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
