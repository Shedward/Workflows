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
import Combine

struct TransitionStepsList: View {
    
    let title: String
    let transition: AnyWorkflowTransition
    let runner: AnyTransitionRunner
    let navigation: Navigation
    
    @SwiftUI.State
    private var progressGroup: ProgressGroup = ProgressGroup()
    
    @SwiftUI.State
    private var progressState: ProgressState = .initial
    
    @SwiftUI.State
    private var run: AnyTransitionRun?
    
    
    init(transition: AnyWorkflowTransition, navigation: Navigation) {
        self.transition = transition
        self.title = transition.name
        self.runner = transition.runner()
        self.navigation = navigation
        
        let progressGroup = ProgressGroup()
        let run = transition.runner().run(totalProgress: progressGroup)
        self._run = .init(initialValue: run)
        self._progressGroup = .init(initialValue: progressGroup)
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
            
            if let run {
                ForEach(run.steps) { step in
                    TransitionStepCell(transitionStep: step)
                        .listRowSeparator(.hidden)
                }
                .onReceive(run.totalProgress.publisher) { progressState in
                    self.progressState = progressState
                }
                .id(run.id)
            }
        }
        .listStyle(.plain)
        .scrollIndicators(.hidden)
        .scrollBounceBehavior(.always)
        .navigationTitle(title)
        .onAppear {
            reloadRun()
        }
    }
    
    private func reloadRun() {
        let progressGroup = ProgressGroup()
        self.progressGroup = progressGroup
        self.run = runner.run(totalProgress: progressGroup)
    }
    
    private func runTransition() {
        reloadRun()
        Task {
            try await run?()
            navigation.popToRoot()
        }
    }
}

#Preview {
    TransitionStepsList(
        transition: AnyWorkflowTransition(
            id: "mock",
            name: "Mock",
            run: AnyTransitionRun(
                totalProgress: ProgressGroup(),
                steps: {
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
        ),
        navigation: Navigation()
    )
}
