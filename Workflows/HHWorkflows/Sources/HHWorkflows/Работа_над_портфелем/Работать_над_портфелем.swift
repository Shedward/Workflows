//
//  Работать_над_портфелем.swift
//  HHWorkflows
//
//  Created by Мальцев Владислав on 03.04.2026.
//

import WorkflowEngine

@DataBindable
struct Работать_над_портфелем: Workflow {
    enum State: String, WorkflowState {
        case исследование
        case декомпозиция
        case разработка
        case тестирование
        case аб_тест
        case ждет_релиза
    }

    var transitions: Transitions {
        afterStart {
            Подготовиться_к_работе_над_портфелем.to(.исследование)
        }

        on(.исследование) {
            Завершить_исследование.to(.декомпозиция)
        }

        on(.декомпозиция) {
            Декомпозиция_портфеля.to(.разработка)
        }

        on(.разработка) {
            Разработка_завершена.to(.тестирование)
        }

        on(.тестирование) {
            Начать_аб_тестирование.to(.аб_тест)
            Найдены_баги.to(.разработка)
        }
    }

    var providers: [any WorkflowStartProvider] {
        Портфели_из_квартального_плана()
    }
}
