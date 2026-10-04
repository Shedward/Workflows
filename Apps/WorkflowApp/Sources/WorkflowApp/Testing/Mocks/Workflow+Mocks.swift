//
//  Workflow+Mocks.swift
//  WorkflowApp
//

import API

extension WorkflowStart {
    enum Mock {
        static let all: [WorkflowStart] = [
            WorkflowStart(workflowId: "Декомпозиция_портфеля", title: "PORTFOLIO-23325: navigation bar v9", data: WorkflowData()),
            WorkflowStart(workflowId: "Декомпозиция_портфеля", title: "PORTFOLIO-23410: profile redesign", data: WorkflowData()),
            WorkflowStart(workflowId: "Код_ревью", title: nil, data: WorkflowData()),
            WorkflowStart(workflowId: "Дейли_стендап", title: nil, data: WorkflowData())
        ]
    }
}
