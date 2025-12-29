//
//  main.swift
//  workflow-cli
//
//  Created by Vlad Maltsev on 24.12.2025.
//

import Core
import Workflow

struct Создать_таблицу_для_декомпозиции: Pass { }
struct Открыть_таблицу: Pass { }
struct Поставить_встречу_для_декомпозиции: Pass { }
struct Текстовая_декомпозиция: Pass { }
struct Автоматическая_декомпозиция: Pass { }
struct Завершить: Pass { }

struct Декомпозиция_портфеля: Workflow {
    enum State: String, WorkflowState {
        static let initial = State.готов_к_декомпозиции
        static let final = State.декомпозиция_завершена

        case готов_к_декомпозиции
        case на_оценке
        case ждем_встречу
        case ждем_ответа_в_треде
        case декомпозиция_завершена
    }

    var transitions: Transitions {
        after(.готов_к_декомпозиции) {
            Создать_таблицу_для_декомпозиции.to(.на_оценке)
        }

        on(.на_оценке) {
            Поставить_встречу_для_декомпозиции.to(.ждем_встречу)
            Текстовая_декомпозиция.to(.ждем_ответа_в_треде)
        }

        on(.ждем_встречу, .ждем_ответа_в_треде) {
            Автоматическая_декомпозиция.toFinish()
        }

        always {
            Завершить.toFinish()
        }
    }
}

struct Разработка_портфеля: Workflow {
    
    enum State: String, WorkflowState {
        static let initial = State.готов_к_разработке
        static let final = State.завершено

        case готов_к_разработке
        case завершено
    }

    var transitions: Transitions {

    }
}
