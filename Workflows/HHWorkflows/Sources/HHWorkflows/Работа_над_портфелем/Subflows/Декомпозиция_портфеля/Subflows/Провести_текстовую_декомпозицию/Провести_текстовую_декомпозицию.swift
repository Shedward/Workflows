//
//  Провести_текстовую_декомпозицию.swift
//  HHWorkflows
//
//  Created by Мальцев Владислав on 05.04.2026.
//

import WorkflowEngine

@DataBindable
struct Провести_текстовую_декомпозицию: Workflow {
    enum State: String, WorkflowState {
        case текстовая_декомпозиция
    }

    var transitions: Transitions {
        onStart {
            Завершить.toFinish()
        }
    }
}
