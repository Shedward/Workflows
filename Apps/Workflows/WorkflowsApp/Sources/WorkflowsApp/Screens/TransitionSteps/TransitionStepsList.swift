//
//  TransitionStepsList.swift
//
//
//  Created by Vlad Maltsev on 07.01.2024.
//

import UI
import SwiftUI
import Workflow
import Prelude

struct TransitionStepsList: View {
    
    let title: String
    let transition: AnyWorkflowTransition
    let transitionSteps: AnyTransitionSteps
    let progressGroup: ProgressProtocol
    let navigation: Navigation
    
    @SwiftUI.State
    private var progressState: ProgressState = .initial
    
    
    init(transition: AnyWorkflowTransition, navigation: Navigation) {
        let progressGroup = ProgressGroup()
        self.transition = transition
        self.title = transition.name
        self.transitionSteps = transition.steps(progress: progressGroup)
        self.progressGroup = progressGroup
        self.navigation = navigation
    }
    
    var body: some View {
        List {
            TransitionStepsHeader(
                workflow: transition.workflow,
                transition: transition,
                onTapRun: runTransition,
                progressState: progressState
            )
            .spacedPadding([.top, .bottom], relative: .d2)
            
            ForEach(transitionSteps.steps) { step in
                TransitionStepCell(transitionStep: step)
                    .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .scrollIndicators(.hidden)
        .scrollBounceBehavior(.always)
        .navigationTitle(title)
        .onReceive(transitionSteps.totalProgress.publisher) { progressState in
            self.progressState = progressState
        }
    }
    
    private func runTransition() {
        Task.detached {
            try await transitionSteps()
            navigation.popToRoot()
        }
    }
}

#Preview {
    TransitionStepsList(
        transition: AnyWorkflowTransition(
            id: "mock",
            name: "Mock",
            steps: AnyTransitionSteps(
                totalProgress: Prelude.Progress(state: .finished)
            ) {
                AnyTransitionStep(
                    id: "1.FirstStep",
                    name: "First Step",
                    progress: Prelude.Progress(state: .finished)
                ) { }
                AnyTransitionStep(
                    id: "2.SecondStep",
                    name: "Second Step",
                    progress: Prelude.Progress(state: .init(value: 0.2))
                ) { }
                AnyTransitionStep(
                    id: "3.ThirdStep",
                    name: "Third Step",
                    progress: Prelude.Progress(state: .initial)
                ) { }
            }
        ),
        navigation: Navigation()
    )
}
