//
//  PortfolioState+StartEstimation.swift
//
//
//  Created by Vlad Maltsev on 06.12.2023.
//

import Workflow
import Prelude

extension PortfolioState {
    struct StartEstimation: Transition {
        
        let id = "Portfolio.StartEstimation"
        let name = "Декомпозировать"
        
        let todo: PortfolioState.ToDo
        
        var steps: TransitionSteps<PortfolioState> {
            .init { workflow in
                TransitionStep(id: "1.GenerateTable", name: "Сгенерировать таблицу") { _ in
                    try await Task.sleep(for: .seconds(1))
                }
                
                TransitionStep(id: "2.MakeDecompositionMeeting", name: "Создать встречу на декомпозицию") { progress in
                    try await Task.sleep(for: .seconds(1))
                    progress.state = .init(value: 0.2)
                    try await Task.sleep(for: .seconds(1))
                }
                
                TransitionStep(id: "3.FailingStep", name: "Шаг с ошибкой") { _ in
                    try await Task.sleep(for: .milliseconds(500))
                    throw Failure("Step failed")
                }
                
                TransitionStep(id: "4.GenerateTasks", name: "Сгенерировать задачи") { _ in
                    let decompositionUrl = "https://sheet.google.com/\(todo.taskId)"
                    try workflow.move(
                        to: .estimation(.init(taskId: todo.taskId, decompositionUrl: decompositionUrl))
                    )
                }
            }
        }
    }
}
