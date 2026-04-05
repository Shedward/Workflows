//
//  Подготовка_к_работе_над_портфелем.swift
//  HHWorkflows
//
//  Created by Мальцев Владислав on 05.04.2026.
//

import WorkflowEngine

@DataBindable
struct Подготовиться_к_работе_над_портфелем: Workflow {
    enum State: String, WorkflowState {
        case создаем_портфельную_ветку
    }

    var transitions: Transitions {
        chainedAfterStart {
            Создать_заметки_для_портфеля.to(.создаем_портфельную_ветку)
            Создать_портфельную_ветку.toFinish()
        }
    }
}
