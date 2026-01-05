//
//  main.swift
//  workflow-cli
//
//  Created by Vlad Maltsev on 24.12.2025.
//

import Core
import Workflow
import os

Logger.enable(.workflow)

struct Создать_таблицу_для_декомпозиции: Pass { }
struct Открыть_таблицу: Pass { }
struct Поставить_встречу_для_декомпозиции: Pass { }
struct Текстовая_декомпозиция: Pass { }
struct Автоматическая_декомпозиция: Pass { }
struct Завершить: Pass { }

@DataBindable
struct Напечатать_сообщение: Action {
    func run() async throws {
        print("Сообщение")
    }
}

@DataBindable
struct Ждать_проведения_встречи: Wait, Defaultable {
    @Input var decompositionDate: String

    func resume() async throws -> Waiting.Time? {
        print("Wait for 1 second")
        return .after(seconds: 1)
    }
}
@DataBindable
struct Ждать_ответов_в_треде: Wait, Defaultable {
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

        on(.встреча_по_декомпозиции) {
            Ждать_проведения_встречи.to(.декомпозиция_проведена)
        }

        on(.текстовая_декомпозиция) {
            Ждать_ответов_в_треде.to(.декомпозиция_завершена)
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

@DataBindable
struct A2B: Action {
    @Input var testText: String
    @Output var output1: String

    func run() async throws {
        print("A2B " + testText)

        output1 = "another test"
    }
}

@DataBindable
struct B2C: Action {
    @Input var output1: String
    @Output var anotherOutput: String

    func run() async throws {
        print("B2C: " + output1)
        anotherOutput = "Finished"
    }
}

struct Проверка_потока_данных: Workflow {

    enum State: String, WorkflowState {
        static let initial = State.a
        static let final = State.c

        case a
        case b
        case c
    }

    var transitions: Transitions {
        after {
            A2B.to(.b)
            B2C.to(.c)
        }
    }
}

let workflows = try await Workflows(
    Декомпозиция_портфеля(),
    Разработка_портфеля(),
    Проверка_потока_данных()
)

let data = WorkflowData(storage: [ DataKey<String>(name: "testText").eraseToAny(): "Hello workflow" ])
var instance = try await workflows.start("Проверка_потока_данных", initialData: data)
print(instance)
let transitions = try await workflows.transitions(for: instance.id)
print(transitions.map(\.id))

