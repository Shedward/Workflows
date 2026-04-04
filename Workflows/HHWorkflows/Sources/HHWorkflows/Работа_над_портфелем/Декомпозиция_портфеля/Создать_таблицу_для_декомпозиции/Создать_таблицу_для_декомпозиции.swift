//
//  Автоматическая_декомпозиция.swift
//  HHWorkflows
//
//  Created by Мальцев Владислав on 26.03.2026.
//

import WorkflowEngine

@DataBindable
struct Создать_таблицу_для_декомпозиции: Workflow {
    enum State: String, WorkflowState {
        case шаблон_скопирован
    }

    @Input
    var portfolioKey: String

    var transitions: Transitions {
        chainedAfterStart {
            Скопировать_шаблон_таблицы_для_декомпозиции.to(.шаблон_скопирован)
            Заполнить_поля_таблицы_декомпозиции.toFinish()
        }
    }
}
