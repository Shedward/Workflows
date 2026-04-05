//
//  Провести_встречу_по_декомпозиции.swift
//  HHWorkflows
//
//  Created by Мальцев Владислав on 05.04.2026.
//

import WorkflowEngine

@DataBindable
struct Провести_встречу_по_декомпозиции: Workflow {
    enum State: String, WorkflowState {
        case создание_встречи
        case проведение_встречи
    }

    var transitions: Transitions {
        chainedAfterStart {
            Создать_комнату_для_декомпозиции.to(.создание_встречи)
            Создать_встречу_для_декомпозиции.to(.проведение_встречи)
        }

        on(.проведение_встречи) {
            Завершить.toFinish()
        }
    }
}
