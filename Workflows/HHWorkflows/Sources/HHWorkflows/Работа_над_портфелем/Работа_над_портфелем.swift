//
//  Работа_над_портфелем.swift
//  HHWorkflows
//
//  Created by Мальцев Владислав on 03.04.2026.
//

import WorkflowEngine

@DataBindable
struct Работа_над_портфелем: Workflow {
    enum State: String, WorkflowState {
        case готово_к_декомпозиции
    }

    var transitions: Transitions {
    }
}
