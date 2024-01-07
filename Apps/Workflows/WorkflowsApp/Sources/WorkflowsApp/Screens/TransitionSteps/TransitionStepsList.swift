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
    let transitionSteps: AnyTransitionSteps
    let progressGroup: ProgressProtocol
    let navigation: Navigation
    
    init(transition: AnyWorkflowTransition, navigation: Navigation) {
        let progressGroup = ProgressGroup()
        self.title = transition.name
        self.transitionSteps = transition.steps(progress: progressGroup)
        self.progressGroup = progressGroup
        self.navigation = navigation
    }
    
    init(mockTransitionSteps: AnyTransitionSteps) {
        self.title = "Mock"
        self.transitionSteps = mockTransitionSteps
        self.progressGroup = ProgressGroup()
        self.navigation = Navigation()
    }
    
    var body: some View {
        SpacedVStack {
            List {
                ForEach(transitionSteps.steps) { step in
                    TransitionStepCell(transitionStep: step)
                        .listRowSeparator(.hidden)
                }
            }
            .listStyle(.plain)
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.always)
        }
        .navigationTitle(title)
    }
}

#Preview {
    TransitionStepsList(
        mockTransitionSteps: AnyTransitionSteps(
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
    )
}
