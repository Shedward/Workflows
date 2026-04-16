//
//  WorkflowInstance+Mocks.swift
//  WorkflowApp
//
//  Created by Мальцев Владислав on 16.04.2026.
//

import API

extension WorkflowInstance {
    enum Mock {
        static let decomposition = WorkflowInstance(
            id: "decomposition-mock",
            workflowId: "Декомпозиция_портфеля",
            state: "заполнение_таблицы_декомпозиции",
            transitionState: nil,
            data: .init()
        )
    }
}
