//
//  main.swift
//  workflow-cli
//
//  Created by Vlad Maltsev on 24.12.2025.
//

import Core
import Workflow

struct Напечатать_сообщение: Action {
    func run() async throws {
        print("Print action")
    }
}

struct Сделать_что_то_еще: Action {
    func run() async throws {
        print("Print action")
    }
}

struct Проверочный_флоу: Workflow {
    enum State: String, WorkflowState {
        static let initial = State.создан

        case создан
        case в_процессе
        case завершен
    }

    var transitions: Transitions {
        from(.создан) {
            Напечатать_сообщение().to(.в_процессе)
            Сделать_что_то_еще().to(.завершен)
        }

        from(.в_процессе) {
            Напечатать_сообщение().to(.завершен)
        }
    }
}


let workflows = try await Workflows(
    Проверочный_флоу()
)

let workflow = try await workflows.start("Проверочный_флоу")
print(workflow)
let instance = try await workflows.instance(id: workflow.id)
print(instance)
let currentTransitions = try await workflows.transitions(for: instance.id)
print(currentTransitions.map(\.id))
try await workflows.startTransition(currentTransitions.first!.id, instance: instance.id)
let updatedInstance = try await workflows.instance(id: workflow.id)
print(updatedInstance)


