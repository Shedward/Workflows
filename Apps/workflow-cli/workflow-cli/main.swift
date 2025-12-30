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

struct Напечатать_сообщение: Action {
    func run() async throws {
        print("Сообщение")
    }
}

struct Ждать_проведения_встречи: Wait {
    func resume() async throws -> Waiting.Time? {
        print("???")
        return .after(minutes: 10)
    }
}

struct Ждать_ответов_в_треде: Wait {
    func resume() async throws -> Waiting.Time? {
        print("???")
        return .after(minutes: 10)
    }
}

struct Декомпозиция_портфеля: Workflow {
    enum State: String, WorkflowState {
        static let initial = State.готов_к_декомпозиции
        static let final = State.декомпозиция_завершена

        case готов_к_декомпозиции
        case на_оценке
        case встреча_по_декомпозиции
        case текстовая_декомпозиция
        case декомпозиция_проведена
        case декомпозиция_завершена
    }

    var transitions: Transitions {
        after(.готов_к_декомпозиции) {
            Создать_таблицу_для_декомпозиции.to(.на_оценке)
        }

        on(.на_оценке) {
            Поставить_встречу_для_декомпозиции.to(.встреча_по_декомпозиции)
            Текстовая_декомпозиция.to(.текстовая_декомпозиция)
        }

        after(.встреча_по_декомпозиции) {
            Ждать_проведения_встречи().to(.декомпозиция_проведена)
        }

        on(.текстовая_декомпозиция) {
            Ждать_ответов_в_треде().to(.декомпозиция_завершена)
        }

        on(.декомпозиция_проведена) {
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
        case декомпозиция_завершена
        case завершено
    }

    var transitions: Transitions {
        on(.готов_к_разработке) {
            Декомпозиция_портфеля().to(.декомпозиция_завершена)

        }
    }
}
