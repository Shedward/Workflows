//
//  Workflow+Mocks.swift
//  WorkflowApp
//

import API

extension Workflow {
    enum Mock {
        static let all: [Workflow] = [
            Workflow(id: "Декомпозиция_портфеля", stateId: [], transitions: []),
            Workflow(id: "Код_ревью", stateId: [], transitions: []),
            Workflow(id: "Дейли_стендап", stateId: [], transitions: []),
        ]
    }
}
