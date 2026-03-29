//
//  Автоматическая_декомпозиция.swift
//  HHWorkflows
//
//  Created by Мальцев Владислав on 26.03.2026.
//

import WorkflowEngine

struct Декомпозиция_портфеля: Workflow {
    enum State: String, WorkflowState {
        case нужно_заполнить_таблицу
        case нужно_провести_декомпозицию
    }

    var transitions: Transitions {
        onStart {
            Создать_таблицу_для_декомпозиции.to(.нужно_заполнить_таблицу)
        }
        on(.нужно_заполнить_таблицу) {
            Таблица_заполнена.to(.нужно_провести_декомпозицию)
        }

        always {
            Завершить.toFinish()
        }
    }
}
