//
//  WorkflowInstance+Mocks.swift
//  WorkflowApp
//
//  Created by Мальцев Владислав on 16.04.2026.
//

import API
import Foundation

extension WorkflowInstance {
    enum Mock {
        static let decomposition = WorkflowInstance(
            id: "decomposition-mock",
            workflowId: "Декомпозиция_портфеля",
            state: "заполнение_таблицы_декомпозиции",
            transitionState: nil,
            data: .init()
        )

        static func simple(id: String = "simple-mock", state: String = "working", finished: Bool = false) -> WorkflowInstance {
            WorkflowInstance(
                id: id,
                workflowId: "Workflow",
                state: state,
                transitionState: nil,
                data: WorkflowData(),
                finishedAt: finished ? Date() : nil
            )
        }

        static func failed(id: String = "failed-mock", error: String = "Network is unreachable") -> WorkflowInstance {
            WorkflowInstance(
                id: id,
                workflowId: "Workflow",
                state: "working",
                transitionState: TransitionState(
                    id: TransitionID(workflow: "Workflow", processId: "Upload", from: "working"),
                    state: .failed(error: ErrorDescription(userDescription: error, debugDescription: error))
                ),
                data: WorkflowData()
            )
        }
    }
}
